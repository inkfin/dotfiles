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
from typing import List, Optional, Tuple

from . import AppError, Tool, engine, log, registry

IS_WINDOWS = sys.platform.startswith("win")

C_RESET = "\x1b[0m"
C_BOLD = "\x1b[1m"
C_DIM = "\x1b[2m"
C_REV = "\x1b[7m"
C_GREEN = "\x1b[32m"
C_YELLOW = "\x1b[33m"
C_CYAN = "\x1b[36m"
C_GRAY = "\x1b[90m"

_ALT_ON = "\x1b[?1049h"
_ALT_OFF = "\x1b[?1049l"
_CLEAR = "\x1b[2J"
_HIDE = "\x1b[?25l"
_SHOW = "\x1b[?25h"

_ANSI_RE = re.compile(r"\x1b\[[0-9;]*m")

_KEYBAR = (
    "space toggle   t toggle all   i install   u update   d uninstall   "
    "m method   s sync   c clean   r rescan   / filter   ? help   q quit"
)


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
    v = _vis_len(s)
    if v > width:
        out: List[str] = []
        n = 0
        for chunk in _ANSI_RE.split(s):
            if not chunk:
                continue
            take = width - n
            if take > 0:
                out.append(chunk[:take])
                n += len(chunk[:take])
            if n >= width:
                break
        s = "".join(out)
    else:
        s = s + " " * (width - v)
    return s


def _wrap(text: str, width: int) -> List[str]:
    if width <= 0:
        return []
    if len(text) <= width:
        return [text]
    words = text.split(" ")
    out: List[str] = []
    cur = ""
    for word in words:
        if not word:
            cur += " "
            continue
        if len(cur) + len(word) + 1 <= width:
            cur = (cur + " " + word).strip()
        else:
            if cur:
                out.append(cur)
            while len(word) > width:
                out.append(word[:width])
                word = word[width:]
            cur = word
    if cur:
        out.append(cur)
    return out


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
            put(inh, _win_modes["in"] & ~ENABLE_ECHO & ~ENABLE_LINE)
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


class TUI:
    _ESCAPE_KEYS = {
        "[A": "up", "[B": "down", "[C": "right", "[D": "left",
        "[H": "home", "[F": "end", "[3~": "delete", "[5~": "pageup", "[6~": "pagedown",
        "[Z": "tab",
    }

    def __init__(self, tools: List[Tool], state: dict) -> None:
        self.tools = [t for t in tools if engine.available_methods(t, engine.platform())]
        self.state = state
        self.visible: List[Tool] = []
        self.cursor = 0
        self.scroll = 0
        self.filter = ""
        self.filter_mode = False
        self.busy = False
        self.help_on = False
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
        try:
            sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        except Exception:
            pass
        self._refresh_probes()
        self._rebuild_visible()

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
                    "H": "up", "P": "down", "K": "left", "M": "right",
                    "G": "home", "O": "end", "I": "pageup", "Q": "pagedown",
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

    def _probe(self, tool: Tool) -> Tuple[bool, Optional[str], Optional[str]]:
        if tool.name not in self._probe_cache:
            entry = self.state["tools"].get(tool.name, {})
            self._probe_cache[tool.name] = engine.probe(tool, entry)
        return self._probe_cache[tool.name]

    def _rebuild_visible(self) -> None:
        f = self.filter.strip().lower()
        self.visible = [
            t for t in self.tools if not f or f in t.name.lower() or f in t.group.lower()
        ]
        if self.cursor >= len(self.visible):
            self.cursor = max(0, len(self.visible) - 1)
        if self.cursor < 0:
            self.cursor = 0

    def _selected_tool(self) -> Optional[Tool]:
        if 0 <= self.cursor < len(self.visible):
            return self.visible[self.cursor]
        return None

    def _chosen_method(self, tool: Tool, entry: dict) -> Optional[str]:
        try:
            name, _, _ = engine.resolve(tool, entry.get("method"))
            return name
        except AppError:
            return None

    # ---- operations --------------------------------------------------------

    def _toggle(self) -> None:
        tool = self._selected_tool()
        if tool is None or self.busy:
            return
        entry = self.state["tools"].setdefault(tool.name, {"enabled": False, "installed": False})
        entry["enabled"] = not entry.get("enabled", False)
        registry.save_state(self.state)

    def _cycle_method(self) -> None:
        tool = self._selected_tool()
        if tool is None or self.busy:
            return
        choices = [n for n, _ in engine.available_methods(tool, engine.platform())]
        if len(choices) < 2:
            return
        entry = self.state["tools"].get(tool.name, {})
        current = entry.get("method") or tool.default_method
        idx = choices.index(current) if current in choices else -1
        entry["method"] = choices[(idx + 1) % len(choices)]
        registry.save_state(self.state)

    def _toggle_all(self) -> None:
        if self.busy:
            return
        states = [self.state["tools"].get(t.name, {}).get("enabled", t.enabled) for t in self.tools]
        target = not any(states) if states else False
        for t in self.tools:
            entry = self.state["tools"].setdefault(t.name, {"enabled": False, "installed": False})
            entry["enabled"] = target
        registry.save_state(self.state)

    def _sync_all(self) -> None:
        ops = []
        for t in self.tools:
            entry = self.state["tools"].get(t.name, {})
            if not entry.get("enabled", t.enabled):
                continue
            status, _, _ = self._probe(t)
            ops.append(("update" if status == "installed" else "install", t))
        if not ops:
            self.log.append("nothing to sync — toggle tools with space/t, then sync")
            return
        self._run_ops(ops)

    def _clean(self) -> None:
        ops = []
        for t in self.tools:
            entry = self.state["tools"].get(t.name, {})
            if entry.get("enabled", t.enabled):
                continue
            status, _, _ = self._probe(t)
            if status == "installed" and entry.get("recipe_kind"):
                ops.append(("uninstall", t))
        if not ops:
            self.log.append("nothing to clean")
            return
        self._run_ops(ops)

    def _run_ops(self, ops) -> None:
        if not ops:
            return
        if self.busy:
            self.log.append("busy — an operation is already running")
            return
        self.busy = True
        self.log = ["apptools: running operations..."]
        self._post(f"apptools: {len(ops)} operation(s)")

        def worker() -> None:
            try:
                for kind, tool in ops:
                    if kind == "install":
                        engine.install(tool, self.state, log=self._post)
                    elif kind == "update":
                        engine.update(tool, self.state, log=self._post)
                    else:
                        engine.uninstall(tool.name, self.state, self.tools, log=self._post)
                self._queue.put(("done", None))
            except AppError as e:
                self._queue.put(("log", f"error: {e}"))
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
                self.log.append(payload)
                del self.log[:-200]
            elif msg == "done":
                self.busy = False
                self._refresh_probes()
                self._rebuild_visible()

    # ---- key handling ------------------------------------------------------

    def _move(self, delta: int) -> None:
        if not self.visible:
            return
        self.cursor = max(0, min(len(self.visible) - 1, self.cursor + delta))

    def _filter_key(self, key: str) -> None:
        if key == "escape":
            self.filter = ""
            self.filter_mode = False
            self._rebuild_visible()
        elif key == "enter":
            self.filter_mode = False
        elif key == "backspace":
            self.filter = self.filter[:-1]
            self._rebuild_visible()
        elif key == "ctrl-c":
            self._quit = True
        elif len(key) == 1:
            self.filter += key
            self._rebuild_visible()

    def _handle(self, key: Optional[str]) -> bool:
        if key is None or self._quit:
            return True
        if self.filter_mode:
            self._filter_key(key)
            return True
        if key == "q" or key == "ctrl-c" or key == "eof":
            return False
        if key == "up":
            self._move(-1)
        elif key == "down":
            self._move(1)
        elif key == "pageup":
            self._move(-max(1, self._list_h))
        elif key == "pagedown":
            self._move(self._list_h)
        elif key == "home":
            self._move(-self.cursor)
        elif key == "end":
            self._move(len(self.visible))
        elif key == "g":
            if self._pending_g:
                self._pending_g = False
                self._move(-self.cursor)
            else:
                self._pending_g = True
        elif key == "G":
            self._pending_g = False
            self._move(len(self.visible))
        elif key == "j":
            self._pending_g = False
            self._move(1)
        elif key == "k":
            self._pending_g = False
            self._move(-1)
        elif key == "space":
            self._toggle()
        elif key == "i" and not self.busy:
            tool = self._selected_tool()
            if tool is not None:
                self._run_ops([("install", tool)])
        elif key == "u" and not self.busy:
            tool = self._selected_tool()
            if tool is not None:
                self._run_ops([("update", tool)])
        elif key == "d" and not self.busy:
            tool = self._selected_tool()
            if tool is not None:
                self._run_ops([("uninstall", tool)])
        elif key == "m" and not self.busy:
            self._cycle_method()
        elif key == "t" and not self.busy:
            self._toggle_all()
        elif key == "s" and not self.busy:
            self._sync_all()
        elif key == "c" and not self.busy:
            self._clean()
        elif key == "r":
            self._refresh_probes()
        elif key in ("slash", "/"):
            self.filter = ""
            self.filter_mode = True
        elif key == "?":
            self.help_on = not self.help_on
        else:
            self._pending_g = False
        return True

    # ---- layout ------------------------------------------------------------

    def _layout(self, w: int, h: int):
        body_top = 2
        body_h = max(1, h - 3)
        narrow = w <= 120
        if narrow:
            detail_h = min(8, max(3, body_h // 3))
            log_h = min(6, max(2, body_h // 4))
            list_h = max(1, body_h - detail_h - log_h)
            list_reg = (0, body_top, w, list_h)
            detail_reg = (0, body_top + list_h, w, detail_h)
            log_reg = (0, body_top + list_h + detail_h, w, log_h)
        else:
            list_w = max(20, int(w * 3 // 5) - 1)
            detail_h = min(12, max(4, body_h // 2))
            list_reg = (0, body_top, list_w, body_h)
            right_x = list_w + 1
            right_w = max(10, w - right_x)
            detail_reg = (right_x, body_top, right_w, detail_h)
            log_reg = (right_x, body_top + detail_h, right_w, max(1, body_h - detail_h))
        return narrow, list_reg, detail_reg, log_reg

    # ---- rendering ---------------------------------------------------------

    def _list_lines(self, width: int) -> List[str]:
        mark_w, method_w, status_w = 2, 8, 20
        name_w = max(6, width - mark_w - method_w - status_w - 2)
        out: List[str] = []
        for i, tool in enumerate(self.visible):
            entry = self.state["tools"].get(tool.name, {})
            status, method, _ = self._probe(tool)
            enabled = entry.get("enabled", tool.enabled)
            mark = (C_GREEN + "✓" + C_RESET) if enabled else (C_GRAY + "✗" + C_RESET)
            name = tool.name[:name_w]
            m = (method or "-")[:method_w]
            if not enabled:
                st = C_GRAY + "disabled" + C_RESET
            elif status == "installed":
                st = C_GREEN + "installed" + C_RESET
            elif status == "external":
                st = C_CYAN + "installed (external)" + C_RESET
            else:
                st = C_YELLOW + "missing" + C_RESET
            line = f"{mark:<{mark_w}}{name:<{name_w}} {m:<{method_w}} {st}"
            if i == self.cursor:
                line = C_REV + line + C_RESET
            out.append(line)
        return out

    def _detail_content(self) -> List[str]:
        if self.help_on:
            return self._help_lines()
        tool = self._selected_tool()
        if tool is None:
            return []
        entry = self.state["tools"].get(tool.name, {})
        status, method, version = self._probe(tool)
        chosen = self._chosen_method(tool, entry) or "-"
        plat = engine.platform()
        out = [tool.name, tool.desc, f"group: {tool.group}", ""]
        avail = engine.available_methods(tool, plat)
        if avail:
            out.append("methods:")
            for mname, mobj in avail:
                recipe = mobj.sources[plat]
                marker = "●" if mname == chosen else "○"
                out.append(f"  {marker} {mname}  {_recipe_summary(recipe)}")
        else:
            out.append("no recipe for this platform")
        if status == "installed":
            state_text = "installed (apptools)"
        elif status == "external":
            state_text = "installed (external — not managed by apptools)"
        else:
            state_text = "not installed"
        out += [
            "",
            f"state: {state_text} ({method or '-'})",
            f"managed: {'yes' if entry.get('enabled', tool.enabled) else 'no'}  (space toggles)",
        ]
        if version:
            out.append(f"version: {version}")
        if entry.get("url"):
            out.append(f"url: {entry['url']}")
        return out

    def _help_lines(self) -> List[str]:
        return [
            "APPTOOLS — per-machine tool manager",
            "",
            "checked (✓) = managed on this machine;",
            "  space/t select which tools to manage.",
            "",
            "MOVEMENT: arrows, j/k, gg/G, pgup/pgdn",
            "",
            "KEYS:",
            "  space  toggle selected       t  toggle all",
            "  i      install selected      u  update selected",
            "  d      uninstall selected    m  cycle install method",
            "  s      sync all enabled      c  clean unmanaged",
            "  r      rescan                /  filter",
            "  ?      this help             q  quit",
            "",
            "m = method: some tools install several ways",
            "  (e.g. neovim: download to ~/.local OR via brew).",
            "  Cycle with m; the active method is marked ●.",
            "",
            "state is stored per machine in",
            "  ~/.local/state/apptools/state.json",
        ]

    def _compose(self, w: int, h: int) -> List[str]:
        _, list_reg, detail_reg, log_reg = self._layout(w, h)
        self._list_h = list_reg[3]
        rows = [""] * h

        title = f"{C_BOLD}apptools{C_RESET}  {len(self.tools)} tools  {engine.platform()}"
        if self.busy:
            title += f"   {C_YELLOW}[working...]{C_RESET}"
        rows[0] = title

        if self.filter_mode:
            rows[1] = "filter: " + self.filter + "▌"
        else:
            rows[1] = C_GRAY + "filter: name or group  ( / to search )" + C_RESET

        lx, ly, lw, lh = list_reg
        if self.cursor < self.scroll:
            self.scroll = self.cursor
        if self.cursor >= self.scroll + lh:
            self.scroll = self.cursor - lh + 1
        self.scroll = max(0, self.scroll)
        lines = self._list_lines(lw)
        for i in range(lh):
            idx = self.scroll + i
            rows[ly + i] = _fit(lines[idx], lw) if idx < len(lines) else " " * lw

        dx, dy, dw, dh = detail_reg
        detail_lines = self._detail_content()
        inner = max(1, dw - 2)
        wrapped: List[str] = []
        for line in detail_lines:
            wrapped.extend(_wrap(line, inner))
        for i in range(dh):
            if i == 0:
                rows[dy + i] = "╭" + "─" * inner + "╮"
            elif i == dh - 1:
                rows[dy + i] = "╰" + "─" * inner + "╯"
            else:
                idx = i - 1
                text = _fit(wrapped[idx], inner) if idx < len(wrapped) else " " * inner
                rows[dy + i] = "│" + text + "│"

        gx, gy, gw, gh = log_reg
        for i in range(gh):
            if i == 0:
                rows[gy + i] = "╭" + "─" * max(1, gw - 2) + "╮"
            elif i == gh - 1:
                rows[gy + i] = "╰" + "─" * max(1, gw - 2) + "╯"
            else:
                idx = len(self.log) - (gh - 1 - i)
                text = _fit(self.log[idx], max(1, gw - 2)) if 0 <= idx < len(self.log) else " " * max(1, gw - 2)
                rows[gy + i] = "│" + text + "│"
        if len(self.log) == 0 and gh > 2:
            rows[gy + 1] = "│" + _fit(C_GRAY + "log — install / update / uninstall output appears here" + C_RESET, max(1, gw - 2)) + "│"

        rows[h - 1] = C_GRAY + _KEYBAR + C_RESET

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
                self._write(_CLEAR)
                for i, line in enumerate(rows):
                    if i >= h:
                        break
                    self._write(f"\x1b[{i + 1};1H" + line + C_RESET)
            else:
                for i, line in enumerate(rows):
                    if line != self._last[i]:
                        self._write(f"\x1b[{i + 1};1H" + line + C_RESET)
        except (BrokenPipeError, OSError):
            self._quit = True
        self._last = rows[:h]
        self._first = False
        sys.stdout.flush()

    # ---- main loop ---------------------------------------------------------

    def _term_size(self) -> Tuple[int, int]:
        try:
            size = shutil.get_terminal_size((80, 24))
            return size.columns, size.lines
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
                    self._rebuild_visible()
                w, h = self._term_size()
                if w != self._width or h != self._height:
                    self._width, self._height = w, h
                    self._first = True
                try:
                    rows = self._compose(w, h)
                    self._emit(rows, w, h)
                    key = self._read_key(0.05)
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
            sys.stdout.flush()
            _win_setup(False)
            _drain_input()
        registry.save_state(self.state)
        return 0


def run(tools: List[Tool], state: dict) -> int:
    from . import log

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
