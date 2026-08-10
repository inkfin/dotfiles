"""Dependency-free full-screen TUI for apptools (Python 3.8+ stdlib only).

Self-contained ANSI rendering with termios/msvcrt key input. It takes over
the terminal explicitly (alternate screen, raw input, no echo), so nothing
from the shell leaks through and every keypress is read exactly once.
"""

from __future__ import annotations

import os
import re
import shutil
import sys
import time
from queue import Empty, Queue
from threading import Thread
from typing import List, Optional, Tuple, Union

from . import AppError, Tool, engine, log, registry

IS_WINDOWS = sys.platform.startswith("win")

C_RESET = "\x1b[0m"
C_BOLD = "\x1b[1m"
C_DIM = "\x1b[2m"
C_REV = "\x1b[7m"
C_UNDER = "\x1b[4m"
C_GREEN = "\x1b[32m"
C_YELLOW = "\x1b[33m"
C_BLUE = "\x1b[34m"
C_MAGENTA = "\x1b[35m"
C_CYAN = "\x1b[36m"
C_RED = "\x1b[31m"
C_GRAY = "\x1b[90m"
C_WHITE = "\x1b[37m"
C_BG_SEL = "\x1b[48;5;236m"
C_BG_HDR = "\x1b[48;5;234m"

_ALT_ON = "\x1b[?1049h"
_ALT_OFF = "\x1b[?1049l"
_CLEAR = "\x1b[2J"
_HIDE = "\x1b[?25l"
_SHOW = "\x1b[?25h"
_HOME = "\x1b[H"

_ANSI_RE = re.compile(r"\x1b\[[0-9;]*[a-zA-Z]")

# view filters: all | managed | missing | installed | external
_VIEW_CYCLE = ("all", "managed", "missing", "installed", "external")
_VIEW_LABEL = {
    "all": "all",
    "managed": "managed",
    "missing": "missing",
    "installed": "installed",
    "external": "external",
}


def _recipe_summary(recipe) -> str:
    from . import Archive, File, Git, Shell

    if isinstance(recipe, Shell):
        return recipe.install
    if isinstance(recipe, Git):
        return f"git {recipe.url}"
    if isinstance(recipe, File):
        return recipe.url
    if isinstance(recipe, Archive):
        tail = f" pick={recipe.pick}" if recipe.pick else ""
        return f"archive {recipe.url}{tail}"
    return type(recipe).__name__


def _vis_len(s: str) -> int:
    return len(_ANSI_RE.sub("", s))


def _fit(s: str, width: int) -> str:
    if width <= 0:
        return ""
    v = _vis_len(s)
    if v > width:
        out: List[str] = []
        n = 0
        buf = s
        i = 0
        while i < len(buf) and n < width:
            if buf[i] == "\x1b":
                m = _ANSI_RE.match(buf, i)
                if m:
                    out.append(m.group(0))
                    i = m.end()
                    continue
            out.append(buf[i])
            n += 1
            i += 1
        s = "".join(out) + C_RESET
    else:
        s = s + " " * (width - v)
    return s


def _wrap(text: str, width: int) -> List[str]:
    if width <= 0:
        return []
    plain = _ANSI_RE.sub("", text)
    if len(plain) <= width:
        return [text]
    words = text.split(" ")
    out: List[str] = []
    cur = ""
    for word in words:
        if not word:
            cur += " "
            continue
        trial = (cur + " " + word).strip() if cur else word
        if _vis_len(trial) <= width:
            cur = trial
        else:
            if cur:
                out.append(cur)
            while _vis_len(word) > width:
                # hard-split long tokens
                chunk = ""
                n = 0
                for ch in word:
                    if n >= width:
                        break
                    chunk += ch
                    n += 1
                out.append(chunk)
                word = word[len(chunk) :]
            cur = word
    if cur:
        out.append(cur)
    return out


def _box_title(title: str, width: int, color: str = C_CYAN) -> str:
    """Top border with inline title: ╭─ title ────╮"""
    inner = max(1, width - 2)
    t = f" {title} "
    tw = _vis_len(t)
    if tw + 2 >= inner:
        t = " " + title[: max(0, inner - 3)] + " "
        tw = _vis_len(t)
    left = 1
    right = max(0, inner - left - tw)
    return "╭" + "─" * left + color + t + C_RESET + "─" * right + "╮"


# ---- Windows console mode --------------------------------------------------

_win_modes: dict = {}


def _win_setup(on: bool) -> None:
    if not IS_WINDOWS:
        return
    try:
        import ctypes

        k32 = ctypes.windll.kernel32
        STD_IN, STD_OUT = -10, -11
        ENABLE_VT = 0x0004
        ENABLE_ECHO = 0x0004
        ENABLE_LINE = 0x0002
        ENABLE_PROCESSED = 0x0001
        ENABLE_QUICK_EDIT = 0x0040

        def get(h):
            m = ctypes.c_uint()
            k32.GetConsoleMode(h, ctypes.byref(m))
            return m.value

        def put(h, m):
            k32.SetConsoleMode(h, m)

        if on:
            inh, outh = k32.GetStdHandle(STD_IN), k32.GetStdHandle(STD_OUT)
            _win_modes["in"] = get(inh)
            _win_modes["out"] = get(outh)
            # raw-ish input: no echo, no line, keep processed for Ctrl+C
            new_in = _win_modes["in"] & ~ENABLE_ECHO & ~ENABLE_LINE
            # disable quick-edit so mouse select doesn't freeze input
            new_in = new_in & ~ENABLE_QUICK_EDIT
            put(inh, new_in)
            put(outh, _win_modes["out"] | ENABLE_VT)
        else:
            put(k32.GetStdHandle(STD_IN), _win_modes.get("in", 0))
            put(k32.GetStdHandle(STD_OUT), _win_modes.get("out", 0))
    except Exception:
        pass


def _drain_input() -> None:
    """Discard any keystrokes still buffered so they don't leak to the shell."""
    if IS_WINDOWS:
        try:
            import ctypes

            k32 = ctypes.windll.kernel32
            k32.FlushConsoleInputBuffer(k32.GetStdHandle(-10))
        except Exception:
            pass
        return
    try:
        import fcntl

        fd = sys.stdin.fileno()
        flags = fcntl.fcntl(fd, fcntl.F_GETFL)
        fcntl.fcntl(fd, fcntl.F_SETFL, flags | os.O_NONBLOCK)
        try:
            while os.read(fd, 4096):
                pass
        except (BlockingIOError, OSError):
            pass
        finally:
            fcntl.fcntl(fd, fcntl.F_SETFL, flags)
    except Exception:
        pass


class _GroupHdr:
    __slots__ = ("group", "count", "collapsed")

    def __init__(self, group: str, count: int, collapsed: bool) -> None:
        self.group = group
        self.count = count
        self.collapsed = collapsed


Row = Union[Tool, _GroupHdr]


class TUI:
    _ESCAPE_KEYS = {
        "[A": "up",
        "[B": "down",
        "[C": "right",
        "[D": "left",
        "[H": "home",
        "[F": "end",
        "[3~": "delete",
        "[5~": "pageup",
        "[6~": "pagedown",
        "[Z": "shift-tab",
    }

    def __init__(self, tools: List[Tool], state: dict) -> None:
        self.tools = [t for t in tools if engine.available_methods(t, engine.platform())]
        self.state = state
        self.rows: List[Row] = []
        self.cursor = 0
        self.scroll = 0
        self.filter = ""
        self.filter_mode = False
        self.view = "all"
        self.collapsed: set = set()
        self.busy = False
        self.help_on = False
        self.confirm: Optional[dict] = None  # {prompt, action}
        self.status_msg = ""
        self.status_until = 0.0
        self.log: List[str] = []
        self._queue: Queue = Queue()
        self._worker: Optional[Thread] = None
        self._probe_cache: dict = {}
        self._kbuf = b""
        self._pending_g = False
        self._last: List[str] = []
        self._first = True
        self._width, self._height = 80, 24
        self._quit = False
        self._list_h = 1
        self._op_total = 0
        self._op_done = 0
        self._spinner_i = 0
        self._spinner_frames = ("⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏")
        try:
            sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        except Exception:
            pass
        self._refresh_probes()
        self._rebuild_rows()

    # ---- key input ---------------------------------------------------------

    def _parse_one(self, buf: bytes) -> Tuple[Optional[str], bytes]:
        if not buf:
            return None, buf
        if buf[0] == 0x1B:
            if len(buf) == 1:
                return "escape", buf[1:]
            if buf[1:2] in (b"[", b"O"):
                j = 2
                while j < len(buf) and not (0x40 <= buf[j] <= 0x7E):
                    j += 1
                if j >= len(buf):
                    return None, buf
                seq = buf[1 : j + 1].decode("ascii", "replace")
                key = self._ESCAPE_KEYS.get(seq)
                if key is None:
                    base = "[" + seq[-1] if seq[0] == "[" else "O" + seq[-1]
                    key = self._ESCAPE_KEYS.get(base, "escape")
                return key, buf[j + 1 :]
            return "escape", buf[1:]
        b = buf[0]
        if b == 0x03:
            return "ctrl-c", buf[1:]
        if b in (0x0D, 0x0A):
            return "enter", buf[1:]
        if b in (0x08, 0x7F):
            return "backspace", buf[1:]
        if b == 0x09:
            return "tab", buf[1:]
        if b == 0x20:
            return "space", buf[1:]
        if b < 0x20:
            return None, buf[1:]
        if b < 0x80:
            return chr(b), buf[1:]
        n = 2 if b & 0xE0 == 0xC0 else (3 if b & 0xF0 == 0xE0 else 4)
        if len(buf) < n:
            return None, buf
        try:
            return buf[:n].decode("utf-8"), buf[n:]
        except UnicodeDecodeError:
            return chr(b), buf[1:]

    def _read_key(self, timeout: float) -> Optional[str]:
        if IS_WINDOWS:
            import msvcrt

            if not msvcrt.kbhit():
                time.sleep(timeout)
                return None
            try:
                ch = msvcrt.getwch()
            except Exception:
                return None
            if ch in ("\x00", "\xe0"):
                try:
                    ch2 = msvcrt.getwch()
                except Exception:
                    return None
                return {
                    "H": "up",
                    "P": "down",
                    "K": "left",
                    "M": "right",
                    "G": "home",
                    "O": "end",
                    "I": "pageup",
                    "Q": "pagedown",
                    "S": "delete",
                }.get(ch2)
            if ch == "\x03":
                return "ctrl-c"
            if ch in ("\r", "\n"):
                return "enter"
            if ch in ("\x08", "\x7f"):
                return "backspace"
            if ch == "\t":
                return "tab"
            if ch == " ":
                return "space"
            if ch == "\x1b":
                seq = b"\x1b"
                while msvcrt.kbhit() and len(seq) < 8:
                    seq += msvcrt.getwch().encode("utf-8", "replace")
                return self._parse_one(seq)[0]
            self._kbuf += ch.encode("utf-8", "replace")
            key, rest = self._parse_one(self._kbuf)
            self._kbuf = rest
            return key
        import select

        fd = sys.stdin.fileno()
        r, _, _ = select.select([fd], [], [], timeout)
        if not r:
            return None
        try:
            data = os.read(fd, 64)
        except OSError:
            return None
        if not data:
            return "eof"
        self._kbuf += data
        key, rest = self._parse_one(self._kbuf)
        self._kbuf = rest
        return key

    # ---- state -------------------------------------------------------------

    def _refresh_probes(self) -> None:
        self._probe_cache = {}

    def _probe(self, tool: Tool) -> Tuple[str, Optional[str], Optional[str]]:
        if tool.name not in self._probe_cache:
            entry = self.state["tools"].get(tool.name, {})
            self._probe_cache[tool.name] = engine.probe(tool, entry)
        return self._probe_cache[tool.name]

    def _is_enabled(self, tool: Tool) -> bool:
        entry = self.state["tools"].get(tool.name, {})
        return bool(entry.get("enabled", tool.enabled))

    def _passes_view(self, tool: Tool) -> bool:
        status, _, _ = self._probe(tool)
        enabled = self._is_enabled(tool)
        v = self.view
        if v == "all":
            return True
        if v == "managed":
            return enabled
        if v == "missing":
            return enabled and status == "missing"
        if v == "installed":
            return status == "installed"
        if v == "external":
            return status == "external"
        return True

    def _rebuild_rows(self) -> None:
        f = self.filter.strip().lower()
        # preserve selection identity across rebuilds
        prev = self._selected_row()
        prev_name = None
        prev_group = None
        if isinstance(prev, Tool):
            prev_name = prev.name
        elif isinstance(prev, _GroupHdr):
            prev_group = prev.group

        filtered: List[Tool] = []
        for t in self.tools:
            if f and f not in t.name.lower() and f not in (t.group or "").lower() and f not in (t.desc or "").lower():
                continue
            if not self._passes_view(t):
                continue
            filtered.append(t)

        # group order: first-seen from catalog, empty group last as "other"
        groups: List[str] = []
        by_g: dict = {}
        for t in filtered:
            g = t.group or "other"
            if g not in by_g:
                by_g[g] = []
                groups.append(g)
            by_g[g].append(t)

        rows: List[Row] = []
        for g in groups:
            items = by_g[g]
            collapsed = g in self.collapsed
            rows.append(_GroupHdr(g, len(items), collapsed))
            if not collapsed:
                rows.extend(items)
        self.rows = rows

        # restore cursor
        new_cur = 0
        if prev_name:
            for i, r in enumerate(self.rows):
                if isinstance(r, Tool) and r.name == prev_name:
                    new_cur = i
                    break
        elif prev_group:
            for i, r in enumerate(self.rows):
                if isinstance(r, _GroupHdr) and r.group == prev_group:
                    new_cur = i
                    break
        self.cursor = max(0, min(new_cur, max(0, len(self.rows) - 1)))

    def _selected_row(self) -> Optional[Row]:
        if 0 <= self.cursor < len(self.rows):
            return self.rows[self.cursor]
        return None

    def _selected_tool(self) -> Optional[Tool]:
        r = self._selected_row()
        return r if isinstance(r, Tool) else None

    def _chosen_method(self, tool: Tool, entry: dict) -> Optional[str]:
        try:
            name, _, _ = engine.resolve(tool, entry.get("method"))
            return name
        except AppError:
            return None

    def _flash(self, msg: str, secs: float = 2.5) -> None:
        self.status_msg = msg
        self.status_until = time.monotonic() + secs

    def _counts(self) -> Tuple[int, int, int, int, int]:
        """enabled, installed, external, missing_enabled, total"""
        en = inst = ext = miss = 0
        for t in self.tools:
            entry = self.state["tools"].get(t.name, {})
            status, _, _ = self._probe(t)
            enabled = entry.get("enabled", t.enabled)
            if enabled:
                en += 1
            if status == "installed":
                inst += 1
            elif status == "external":
                ext += 1
            if enabled and status == "missing":
                miss += 1
        return en, inst, ext, miss, len(self.tools)

    # ---- operations --------------------------------------------------------

    def _toggle(self) -> None:
        row = self._selected_row()
        if row is None or self.busy:
            return
        if isinstance(row, _GroupHdr):
            if row.group in self.collapsed:
                self.collapsed.discard(row.group)
            else:
                self.collapsed.add(row.group)
            self._rebuild_rows()
            return
        tool = row
        entry = self.state["tools"].setdefault(tool.name, {"enabled": False, "installed": False})
        entry["enabled"] = not entry.get("enabled", False)
        registry.save_state(self.state)
        # keep row identity; may drop from filtered view
        if self.view != "all":
            self._rebuild_rows()

    def _cycle_method(self) -> None:
        tool = self._selected_tool()
        if tool is None or self.busy:
            return
        choices = [n for n, _ in engine.available_methods(tool, engine.platform())]
        if len(choices) < 2:
            self._flash("only one install method available")
            return
        entry = self.state["tools"].setdefault(tool.name, {"enabled": False, "installed": False})
        current = entry.get("method") or tool.default_method
        idx = choices.index(current) if current in choices else -1
        entry["method"] = choices[(idx + 1) % len(choices)]
        registry.save_state(self.state)
        self._refresh_probes()
        self._flash(f"{tool.name}: method → {entry['method']}")

    def _toggle_all(self) -> None:
        if self.busy:
            return
        # operate on currently visible tools only (respects filter/view)
        visible_tools = [r for r in self.rows if isinstance(r, Tool)]
        if not visible_tools:
            return
        states = [self._is_enabled(t) for t in visible_tools]
        target = not any(states)
        for t in visible_tools:
            entry = self.state["tools"].setdefault(t.name, {"enabled": False, "installed": False})
            entry["enabled"] = target
        registry.save_state(self.state)
        if self.view != "all":
            self._rebuild_rows()
        self._flash(("enabled" if target else "disabled") + f" {len(visible_tools)} tool(s)")

    def _sync_all(self) -> None:
        ops = []
        for t in self.tools:
            if not self._is_enabled(t):
                continue
            status, _, _ = self._probe(t)
            ops.append(("update" if status == "installed" else "install", t))
        if not ops:
            self._flash("nothing to sync — enable tools with space, then s")
            return
        self._ask_confirm(
            f"sync {len(ops)} enabled tool(s)? [y/N]",
            lambda: self._run_ops(ops),
        )

    def _apply_missing(self) -> None:
        ops = []
        for t in self.tools:
            if not self._is_enabled(t):
                continue
            status, _, _ = self._probe(t)
            if status != "installed":
                ops.append(("install", t))
        if not ops:
            self._flash("nothing missing — all enabled tools are installed")
            return
        self._ask_confirm(
            f"install {len(ops)} missing tool(s)? [y/N]",
            lambda: self._run_ops(ops),
        )

    def _clean(self) -> None:
        ops = []
        names = []
        for t in self.tools:
            entry = self.state["tools"].get(t.name, {})
            if entry.get("enabled", t.enabled):
                continue
            status, _, _ = self._probe(t)
            if status == "installed" and entry.get("recipe_kind"):
                ops.append(("uninstall", t))
                names.append(t.name)
        orphans = registry.orphans(self.state, self.tools)
        # orphans handled inside engine.uninstall via name
        for name in orphans:
            # fabricate a stub only if not already listed
            if name not in names:
                names.append(name)
                # uninstall by name using a dummy Tool-less path via callback
                ops.append(("uninstall_name", name))
        if not ops:
            self._flash("nothing to clean")
            return
        preview = ", ".join(names[:6]) + ("…" if len(names) > 6 else "")
        self._ask_confirm(
            f"uninstall {len(ops)} unmanaged: {preview}? [y/N]",
            lambda: self._run_ops(ops),
        )

    def _ask_confirm(self, prompt: str, action) -> None:
        self.confirm = {"prompt": prompt, "action": action}

    def _run_ops(self, ops) -> None:
        if not ops:
            return
        if self.busy:
            self._flash("busy — wait for the current operation")
            return
        self.busy = True
        self._op_total = len(ops)
        self._op_done = 0
        self.log = [f"running {len(ops)} operation(s)…"]
        self._post(f"——— {len(ops)} op(s) ———")

        def worker() -> None:
            errors = 0
            try:
                for kind, target in ops:
                    try:
                        if kind == "install":
                            engine.install(target, self.state, log=self._post)
                        elif kind == "update":
                            engine.update(target, self.state, log=self._post)
                        elif kind == "uninstall":
                            engine.uninstall(target.name, self.state, self.tools, log=self._post)
                        elif kind == "uninstall_name":
                            engine.uninstall(target, self.state, self.tools, log=self._post)
                    except AppError as e:
                        errors += 1
                        self._queue.put(("log", f"error: {e}"))
                    except Exception as e:
                        errors += 1
                        self._queue.put(("log", f"error: {e!r}"))
                    self._queue.put(("progress", None))
                if errors:
                    self._queue.put(("log", f"finished with {errors} error(s)"))
                else:
                    self._queue.put(("log", "all done."))
                self._queue.put(("done", None))
            except Exception as e:
                self._queue.put(("log", f"error: {e!r}"))
                self._queue.put(("done", None))

        self._worker = Thread(target=worker, daemon=True)
        self._worker.start()

    def _post(self, line: str) -> None:
        self._queue.put(("log", line))

    def _drain(self) -> None:
        while True:
            try:
                msg, payload = self._queue.get_nowait()
            except Empty:
                return
            if msg == "log":
                self.log.append(str(payload))
                del self.log[:-300]
            elif msg == "progress":
                self._op_done = min(self._op_total, self._op_done + 1)
            elif msg == "done":
                self.busy = False
                self._refresh_probes()
                self._rebuild_rows()

    # ---- key handling ------------------------------------------------------

    def _move(self, delta: int) -> None:
        if not self.rows:
            return
        self.cursor = max(0, min(len(self.rows) - 1, self.cursor + delta))

    def _filter_key(self, key: str) -> None:
        if key == "escape":
            self.filter = ""
            self.filter_mode = False
            self._rebuild_rows()
        elif key == "enter":
            self.filter_mode = False
        elif key == "backspace":
            self.filter = self.filter[:-1]
            self._rebuild_rows()
        elif key == "ctrl-c":
            self._quit = True
        elif len(key) == 1:
            self.filter += key
            self._rebuild_rows()

    def _handle_confirm(self, key: str) -> None:
        if key in ("y", "Y", "enter"):
            action = self.confirm["action"] if self.confirm else None
            self.confirm = None
            if action:
                action()
        elif key in ("n", "N", "escape", "q"):
            self.confirm = None
            self._flash("cancelled")
        # ignore other keys while confirming

    def _handle(self, key: Optional[str]) -> bool:
        if key is None or self._quit:
            return True
        if self.confirm is not None:
            self._handle_confirm(key)
            return True
        if self.filter_mode:
            self._filter_key(key)
            return True
        if key == "eof":
            return False
        if key == "ctrl-c":
            return False  # always allow force quit
        if key == "q":
            if self.busy:
                self._flash("operation running — ctrl-c force quits")
                return True
            return False

        if key == "up" or key == "k":
            self._pending_g = False
            self._move(-1)
        elif key == "down" or key == "j":
            self._pending_g = False
            self._move(1)
        elif key == "pageup":
            self._pending_g = False
            self._move(-max(1, self._list_h))
        elif key == "pagedown":
            self._pending_g = False
            self._move(self._list_h)
        elif key == "home":
            self._pending_g = False
            self._move(-self.cursor)
        elif key == "end":
            self._pending_g = False
            self._move(len(self.rows))
        elif key == "g":
            if self._pending_g:
                self._pending_g = False
                self._move(-self.cursor)
            else:
                self._pending_g = True
        elif key == "G":
            self._pending_g = False
            self._move(len(self.rows))
        elif key == "h" or key == "left":
            # collapse group of selected tool / collapse header
            self._pending_g = False
            row = self._selected_row()
            if isinstance(row, _GroupHdr):
                self.collapsed.add(row.group)
                self._rebuild_rows()
            elif isinstance(row, Tool):
                g = row.group or "other"
                self.collapsed.add(g)
                self._rebuild_rows()
                # land on header
                for i, r in enumerate(self.rows):
                    if isinstance(r, _GroupHdr) and r.group == g:
                        self.cursor = i
                        break
        elif key == "l" or key == "right" or key == "enter":
            self._pending_g = False
            row = self._selected_row()
            if isinstance(row, _GroupHdr):
                if row.group in self.collapsed:
                    self.collapsed.discard(row.group)
                else:
                    self.collapsed.add(row.group)
                self._rebuild_rows()
        elif key == "space":
            self._pending_g = False
            self._toggle()
        elif key == "i" and not self.busy:
            self._pending_g = False
            tool = self._selected_tool()
            if tool is not None:
                # auto-enable on install
                entry = self.state["tools"].setdefault(tool.name, {"enabled": False, "installed": False})
                if not entry.get("enabled"):
                    entry["enabled"] = True
                    registry.save_state(self.state)
                self._run_ops([("install", tool)])
        elif key == "u" and not self.busy:
            self._pending_g = False
            tool = self._selected_tool()
            if tool is not None:
                self._run_ops([("update", tool)])
        elif key == "d" and not self.busy:
            self._pending_g = False
            tool = self._selected_tool()
            if tool is not None:
                self._ask_confirm(
                    f"uninstall {tool.name}? [y/N]",
                    lambda t=tool: self._run_ops([("uninstall", t)]),
                )
        elif key == "m" and not self.busy:
            self._pending_g = False
            self._cycle_method()
        elif key == "t" and not self.busy:
            self._pending_g = False
            self._toggle_all()
        elif key == "s" and not self.busy:
            self._pending_g = False
            self._sync_all()
        elif key == "a" and not self.busy:
            self._pending_g = False
            self._apply_missing()
        elif key == "c" and not self.busy:
            self._pending_g = False
            self._clean()
        elif key == "r":
            self._pending_g = False
            self._refresh_probes()
            self._rebuild_rows()
            self._flash("rescanned")
        elif key == "f":
            self._pending_g = False
            idx = _VIEW_CYCLE.index(self.view) if self.view in _VIEW_CYCLE else 0
            self.view = _VIEW_CYCLE[(idx + 1) % len(_VIEW_CYCLE)]
            self._rebuild_rows()
            self._flash(f"view: {_VIEW_LABEL[self.view]}")
        elif key == "F":
            self._pending_g = False
            idx = _VIEW_CYCLE.index(self.view) if self.view in _VIEW_CYCLE else 0
            self.view = _VIEW_CYCLE[(idx - 1) % len(_VIEW_CYCLE)]
            self._rebuild_rows()
            self._flash(f"view: {_VIEW_LABEL[self.view]}")
        elif key == "z":
            # collapse / expand all groups
            self._pending_g = False
            groups = {r.group for r in self.rows if isinstance(r, _GroupHdr)}
            if groups and groups <= self.collapsed:
                self.collapsed.clear()
                self._flash("expanded all groups")
            else:
                self.collapsed = set(groups) | {
                    (t.group or "other") for t in self.tools
                }
                self._flash("collapsed all groups")
            self._rebuild_rows()
        elif key in ("slash", "/"):
            self._pending_g = False
            self.filter_mode = True
            # searching implies looking across the catalog
            if self.view != "all":
                self.view = "all"
                self._rebuild_rows()

        elif key == "?":
            self._pending_g = False
            self.help_on = not self.help_on
        elif key == "escape":
            self._pending_g = False
            if self.help_on:
                self.help_on = False
            elif self.filter:
                self.filter = ""
                self._rebuild_rows()
            elif self.view != "all":
                self.view = "all"
                self._rebuild_rows()
        else:
            self._pending_g = False
        return True

    # ---- layout ------------------------------------------------------------

    def _layout(self, w: int, h: int):
        # rows: 0 title, 1 stats, 2 filter, body..., h-2 status, h-1 keybar
        body_top = 3
        body_h = max(1, h - 5)
        narrow = w < 100
        if narrow:
            detail_h = min(9, max(4, body_h // 3))
            log_h = min(6, max(3, body_h // 4))
            list_h = max(1, body_h - detail_h - log_h)
            list_reg = (0, body_top, w, list_h)
            detail_reg = (0, body_top + list_h, w, detail_h)
            log_reg = (0, body_top + list_h + detail_h, w, log_h)
        else:
            list_w = max(28, int(w * 0.55))
            list_reg = (0, body_top, list_w, body_h)
            right_x = list_w + 1
            right_w = max(20, w - right_x)
            detail_h = min(14, max(6, body_h * 55 // 100))
            detail_reg = (right_x, body_top, right_w, detail_h)
            log_reg = (right_x, body_top + detail_h, right_w, max(3, body_h - detail_h))
        return narrow, list_reg, detail_reg, log_reg

    # ---- rendering ---------------------------------------------------------

    def _status_glyph(self, status: str, enabled: bool) -> str:
        if not enabled:
            return C_GRAY + "·" + C_RESET
        if status == "installed":
            return C_GREEN + "●" + C_RESET
        if status == "external":
            return C_CYAN + "◐" + C_RESET
        return C_YELLOW + "○" + C_RESET

    def _list_lines(self, width: int) -> List[str]:
        # columns: mark(1) name  method  status
        method_w = 9
        status_w = 10
        name_w = max(8, width - 2 - method_w - status_w - 3)
        out: List[str] = []
        for i, row in enumerate(self.rows):
            if isinstance(row, _GroupHdr):
                arrow = "▸" if row.collapsed else "▾"
                label = f" {arrow} {row.group} "
                count = f"({row.count})"
                pad = max(0, width - _vis_len(label) - len(count) - 1)
                line = (
                    C_BG_HDR
                    + C_BOLD
                    + C_MAGENTA
                    + label
                    + C_RESET
                    + C_BG_HDR
                    + C_GRAY
                    + " " * pad
                    + count
                    + " "
                    + C_RESET
                )
            else:
                tool = row
                entry = self.state["tools"].get(tool.name, {})
                status, method, _ = self._probe(tool)
                enabled = entry.get("enabled", tool.enabled)
                mark = self._status_glyph(status, enabled)
                # checkbox for managed
                box = (C_GREEN + "✓" + C_RESET) if enabled else (C_GRAY + " " + C_RESET)
                name = tool.name[:name_w]
                m = (method or "-")[:method_w]
                if not enabled:
                    st = C_GRAY + "off" + C_RESET
                elif status == "installed":
                    st = C_GREEN + "ok" + C_RESET
                elif status == "external":
                    st = C_CYAN + "ext" + C_RESET
                else:
                    st = C_YELLOW + "miss" + C_RESET
                line = f"{box}{mark} {name:<{name_w}} {C_DIM}{m:<{method_w}}{C_RESET} {st}"
            if i == self.cursor:
                # reverse whole line for clear selection
                plain = _ANSI_RE.sub("", line)
                line = C_REV + C_BOLD + plain[:width] + C_RESET
            out.append(line)
        return out

    def _detail_content(self) -> List[str]:
        if self.help_on:
            return self._help_lines()
        row = self._selected_row()
        if row is None:
            return [C_GRAY + "no tools match filter/view" + C_RESET]
        if isinstance(row, _GroupHdr):
            return [
                f"{C_BOLD}{row.group}{C_RESET}",
                f"{row.count} tool(s)  ·  {'collapsed' if row.collapsed else 'expanded'}",
                "",
                C_GRAY + "enter/l toggle group   h collapse   z all" + C_RESET,
                C_GRAY + "space on header also toggles fold" + C_RESET,
            ]
        tool = row
        entry = self.state["tools"].get(tool.name, {})
        status, method, version = self._probe(tool)
        chosen = self._chosen_method(tool, entry) or "-"
        plat = engine.platform()
        enabled = entry.get("enabled", tool.enabled)

        out: List[str] = [
            f"{C_BOLD}{tool.name}{C_RESET}",
            tool.desc or C_GRAY + "(no description)" + C_RESET,
            f"{C_GRAY}group{C_RESET} {tool.group or '—'}    {C_GRAY}platform{C_RESET} {plat}",
            "",
        ]

        # managed / state badges
        mg = (C_GREEN + "managed" + C_RESET) if enabled else (C_GRAY + "not managed" + C_RESET)
        if status == "installed":
            st = C_GREEN + "installed (apptools)" + C_RESET
        elif status == "external":
            st = C_CYAN + "external (on PATH)" + C_RESET
        else:
            st = C_YELLOW + "missing" + C_RESET
        out.append(f"{mg}  ·  {st}")
        if version:
            out.append(f"{C_GRAY}version{C_RESET}  {version}")
        if entry.get("updated_at"):
            out.append(f"{C_GRAY}updated{C_RESET}  {entry['updated_at']}")
        if entry.get("url"):
            out.append(f"{C_GRAY}url{C_RESET}      {entry['url']}")
        if entry.get("managed_dir"):
            out.append(f"{C_GRAY}dir{C_RESET}      {entry['managed_dir']}")

        avail = engine.available_methods(tool, plat)
        out.append("")
        if avail:
            out.append(f"{C_BOLD}methods{C_RESET}  {C_GRAY}(m to cycle){C_RESET}")
            for mname, mobj in avail:
                recipe = mobj.sources[plat]
                if mname == chosen:
                    marker = C_GREEN + "●" + C_RESET
                    name_s = C_BOLD + mname + C_RESET
                else:
                    marker = C_GRAY + "○" + C_RESET
                    name_s = mname
                summary = _recipe_summary(recipe)
                out.append(f"  {marker} {name_s}")
                out.append(f"      {C_DIM}{summary}{C_RESET}")
        else:
            out.append(C_RED + "no recipe for this platform" + C_RESET)

        out += [
            "",
            C_GRAY + "space manage  i install  u update  d remove" + C_RESET,
        ]
        return out

    def _help_lines(self) -> List[str]:
        return [
            f"{C_BOLD}apptools{C_RESET} — per-machine tool manager",
            "",
            f"{C_CYAN}mental model{C_RESET}",
            "  ✓ managed = keep this tool on this machine",
            "  ● ok / ◐ external / ○ missing  (live probe)",
            "  s sync = install missing + update installed",
            "  c clean = remove installed but not managed",
            "",
            f"{C_CYAN}movement{C_RESET}",
            "  j/k ↑↓   gg/G   pgup/pgdn   h/l fold groups",
            "",
            f"{C_CYAN}actions{C_RESET}",
            "  space  toggle managed (or fold group)",
            "  t      toggle all visible",
            "  i/u/d  install / update / uninstall selected",
            "  m      cycle install method",
            "  a      apply (install missing enabled)",
            "  s      sync all enabled",
            "  c      clean unmanaged installs",
            "  r      rescan probes",
            "",
            f"{C_CYAN}views{C_RESET}",
            "  /      filter by name/group/desc",
            "  f/F    cycle view filter",
            "  z      collapse/expand all groups",
            "  ?      toggle this help   q quit",
            "",
            f"{C_GRAY}state ~/.local/state/apptools/state.json{C_RESET}",
            f"{C_GRAY}catalog ~/.config/apptools/config.py{C_RESET}",
        ]

    def _keybar(self, w: int) -> str:
        if self.confirm is not None:
            return C_YELLOW + C_BOLD + " " + self.confirm["prompt"] + C_RESET
        if self.filter_mode:
            return C_GRAY + " type to filter · enter apply · esc clear " + C_RESET
        if self.busy:
            spin = self._spinner_frames[self._spinner_i % len(self._spinner_frames)]
            prog = f"{self._op_done}/{self._op_total}" if self._op_total else ""
            return (
                C_YELLOW
                + f" {spin} working {prog}  ·  keys locked until done  ·  ctrl-c force quit "
                + C_RESET
            )
        parts = [
            ("space", "toggle"),
            ("i/u/d", "inst/up/rm"),
            ("m", "method"),
            ("a", "apply"),
            ("s", "sync"),
            ("c", "clean"),
            ("f", "view"),
            ("/", "filter"),
            ("?", "help"),
            ("q", "quit"),
        ]
        bits = []
        for k, label in parts:
            bits.append(f"{C_BOLD}{k}{C_RESET}{C_GRAY} {label}{C_RESET}")
        return " " + f"{C_GRAY} · {C_RESET}".join(bits) + " "

    def _compose(self, w: int, h: int) -> List[str]:
        _, list_reg, detail_reg, log_reg = self._layout(w, h)
        self._list_h = list_reg[3]
        rows = [""] * h

        en, inst, ext, miss, total = self._counts()
        plat = engine.platform()

        # title
        brand = f"{C_BOLD}{C_CYAN}apptools{C_RESET}"
        title = f" {brand}  {C_GRAY}{total} tools · {plat}{C_RESET}"
        if self.busy:
            spin = self._spinner_frames[self._spinner_i % len(self._spinner_frames)]
            title += f"  {C_YELLOW}{spin} working {self._op_done}/{self._op_total}{C_RESET}"
        rows[0] = title

        # stats strip
        def chip(label: str, n: int, color: str) -> str:
            return f"{color}{n}{C_RESET}{C_GRAY} {label}{C_RESET}"

        stats = "  ".join(
            [
                chip("managed", en, C_GREEN if en else C_GRAY),
                chip("ok", inst, C_GREEN if inst else C_GRAY),
                chip("ext", ext, C_CYAN if ext else C_GRAY),
                chip("missing", miss, C_YELLOW if miss else C_GRAY),
            ]
        )
        view_s = f"{C_GRAY}view{C_RESET} {C_BOLD}{_VIEW_LABEL[self.view]}{C_RESET}"
        rows[1] = f" {stats}    {view_s}"

        # filter line
        if self.filter_mode:
            rows[2] = f" {C_YELLOW}/{C_RESET} {self.filter}{C_BOLD}▌{C_RESET}"
        elif self.filter:
            rows[2] = f" {C_GRAY}filter:{C_RESET} {self.filter}  {C_GRAY}(esc clear · / edit){C_RESET}"
        else:
            rows[2] = f" {C_GRAY}/ filter   f view   z groups   ? help{C_RESET}"

        # list
        lx, ly, lw, lh = list_reg
        if self.cursor < self.scroll:
            self.scroll = self.cursor
        if self.cursor >= self.scroll + lh:
            self.scroll = self.cursor - lh + 1
        self.scroll = max(0, min(self.scroll, max(0, len(self.rows) - lh)))
        lines = self._list_lines(lw)
        for i in range(lh):
            idx = self.scroll + i
            if idx < len(lines):
                rows[ly + i] = _fit(lines[idx], lw)
            else:
                rows[ly + i] = " " * lw

        # detail pane
        dx, dy, dw, dh = detail_reg
        detail_lines = self._detail_content()
        inner = max(1, dw - 2)
        wrapped: List[str] = []
        for line in detail_lines:
            wrapped.extend(_wrap(line, inner))
        title_d = "help" if self.help_on else "detail"
        for i in range(dh):
            if i == 0:
                rows[dy + i] = _box_title(title_d, dw, C_CYAN)
            elif i == dh - 1:
                rows[dy + i] = "╰" + "─" * inner + "╯"
            else:
                idx = i - 1
                text = _fit(wrapped[idx], inner) if idx < len(wrapped) else " " * inner
                rows[dy + i] = "│" + text + "│"

        # log pane
        gx, gy, gw, gh = log_reg
        inner_g = max(1, gw - 2)
        log_title = "log"
        if self.busy and self._op_total:
            log_title = f"log  {self._op_done}/{self._op_total}"
        for i in range(gh):
            if i == 0:
                rows[gy + i] = _box_title(log_title, gw, C_YELLOW if self.busy else C_GRAY)
            elif i == gh - 1:
                rows[gy + i] = "╰" + "─" * inner_g + "╯"
            else:
                # show newest at bottom
                slot = i - 1
                n_slots = gh - 2
                idx = len(self.log) - n_slots + slot
                if 0 <= idx < len(self.log):
                    raw = self.log[idx]
                    if raw.startswith("error"):
                        raw = C_RED + raw + C_RESET
                    elif raw.startswith("apptools:") or raw.startswith("———") or raw.startswith("running"):
                        raw = C_CYAN + raw + C_RESET
                    elif raw.startswith("$ "):
                        raw = C_DIM + raw + C_RESET
                    text = _fit(raw, inner_g)
                elif len(self.log) == 0 and slot == 0:
                    text = _fit(
                        C_GRAY + "output from install / update / uninstall" + C_RESET,
                        inner_g,
                    )
                else:
                    text = " " * inner_g
                rows[gy + i] = "│" + text + "│"

        # status + keybar
        if self.confirm is not None:
            rows[h - 2] = _fit(
                C_YELLOW + C_BOLD + " " + self.confirm["prompt"] + C_RESET,
                w,
            )
        elif self.status_msg and time.monotonic() < self.status_until:
            rows[h - 2] = _fit(f" {C_CYAN}{self.status_msg}{C_RESET}", w)
        else:
            # scroll indicator / selection position
            if self.rows:
                pos = f"{self.cursor + 1}/{len(self.rows)}"
            else:
                pos = "0/0"
            rows[h - 2] = _fit(f" {C_GRAY}{pos}{C_RESET}", w)

        rows[h - 1] = _fit(self._keybar(w), w)
        return [_fit(r, w) for r in rows]

    def _write(self, s: str) -> None:
        if self._quit:
            return
        try:
            sys.stdout.write(s)
        except (BrokenPipeError, OSError):
            self._quit = True

    def _emit(self, rows: List[str], w: int, h: int) -> None:
        first = self._first or not self._last or len(rows) != len(self._last)
        try:
            if first:
                self._write(_CLEAR + _HOME)
                for i, line in enumerate(rows):
                    if i >= h:
                        break
                    self._write(f"\x1b[{i + 1};1H" + line + C_RESET)
            else:
                for i, line in enumerate(rows):
                    if i < len(self._last) and line == self._last[i]:
                        continue
                    self._write(f"\x1b[{i + 1};1H" + line + C_RESET + "\x1b[K")
        except (BrokenPipeError, OSError):
            self._quit = True
        self._last = list(rows[:h])
        self._first = False
        try:
            sys.stdout.flush()
        except (BrokenPipeError, OSError):
            self._quit = True

    # ---- main loop ---------------------------------------------------------

    def _term_size(self) -> Tuple[int, int]:
        try:
            size = shutil.get_terminal_size((80, 24))
            return max(40, size.columns), max(12, size.lines)
        except OSError:
            return 80, 24

    def loop(self) -> int:
        self._width, self._height = self._term_size()
        _win_setup(True)
        self._write(_ALT_ON + _HIDE + _CLEAR)
        sys.stdout.flush()
        termios_ctx = None
        if not IS_WINDOWS:
            try:
                import termios
                import tty

                fd = sys.stdin.fileno()
                termios_ctx = (termios, fd, termios.tcgetattr(fd))
                tty.setraw(fd)
            except Exception:
                termios_ctx = None
        try:
            while not self._quit:
                self._drain()
                if self.busy and self._worker is not None and not self._worker.is_alive():
                    self.busy = False
                    self.log.append("error: operation thread exited unexpectedly")
                    self._refresh_probes()
                    self._rebuild_rows()
                if self.busy:
                    self._spinner_i += 1
                w, h = self._term_size()
                if w != self._width or h != self._height:
                    self._width, self._height = w, h
                    self._first = True
                try:
                    composed = self._compose(w, h)
                    self._emit(composed, w, h)
                    key = self._read_key(0.05 if not self.busy else 0.08)
                    if key is None:
                        continue
                    if not self._handle(key):
                        break
                except Exception:
                    log.exception("TUI loop")
                    self.log.append("error: internal error (see apptools.log)")
                    self.busy = False
        except KeyboardInterrupt:
            pass
        finally:
            if termios_ctx is not None:
                termios, fd, old = termios_ctx
                try:
                    termios.tcsetattr(fd, termios.TCSADRAIN, old)
                except Exception:
                    pass
            self._write(_SHOW + C_RESET + _CLEAR + _ALT_OFF)
            try:
                sys.stdout.flush()
            except Exception:
                pass
            _win_setup(False)
            _drain_input()
        try:
            registry.save_state(self.state)
        except Exception:
            log.exception("save_state on exit")
        return 0


def run(tools: List[Tool], state: dict) -> int:
    if not sys.stdin.isatty() or not sys.stdout.isatty():
        print("apptools: TUI needs an interactive terminal.")
        print("hint: use `apptools list`, `apptools apply`, or `apptools install <name>`")
        return 1
    try:
        return TUI(tools, state).loop()
    except Exception:
        log.exception("TUI")
        print("apptools: TUI crashed (see log: " + str(log.log_path()) + ")", file=sys.stderr)
        return 1
