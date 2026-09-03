#!/usr/bin/env python3
"""Cursor CLI statusline — compact lualine-style footer."""
from __future__ import annotations

import json
import os
import subprocess
import sys

RESET = "\033[0m"
DIM = "\033[2m"
BOLD = "\033[1m"


def fg(n: int) -> str:
    return f"\033[38;5;{n}m"


def bg(n: int) -> str:
    return f"\033[48;5;{n}m"


def git(cwd: str, *args: str) -> str:
    try:
        env = os.environ.copy()
        env["GIT_OPTIONAL_LOCKS"] = "0"
        r = subprocess.run(
            ["git", "-C", cwd, *args],
            capture_output=True,
            text=True,
            timeout=0.2,
            env=env,
        )
        if r.returncode == 0:
            return r.stdout.strip()
    except Exception:
        pass
    return ""


def bar(pct: int, width: int = 10) -> str:
    pct = max(0, min(100, pct))
    filled = round(pct * width / 100)
    color = 114 if pct < 60 else 221 if pct < 85 else 203
    return (
        f"{fg(color)}{'▰' * filled}{fg(238)}{'▱' * (width - filled)}{RESET}"
        f" {fg(color)}{pct}%{RESET}"
    )


def vis(s: str) -> int:
    raw = ""
    i = 0
    while i < len(s):
        if s.startswith("\033[", i):
            end = s.find("m", i)
            i = len(s) if end < 0 else end + 1
            continue
        raw += s[i]
        i += 1
    return len(raw)


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 1

    model = payload.get("model") or {}
    ctx = payload.get("context_window") or {}
    workspace = payload.get("workspace") or {}
    vim = payload.get("vim") or {}
    worktree = payload.get("worktree") or {}

    cwd = (
        payload.get("cwd")
        or workspace.get("current_dir")
        or os.getcwd()
    )
    project = os.path.basename(os.path.abspath(cwd.rstrip(os.sep)) or cwd) or cwd

    parts: list[str] = []

    mode = vim.get("mode")
    if mode:
        parts.append(f"{BOLD}{bg(24)}{fg(15)} {mode} {RESET}")

    parts.append(f"{fg(111)}{project}{RESET}")

    branch = git(cwd, "branch", "--show-current")
    if not branch:
        branch = git(cwd, "rev-parse", "--short", "HEAD")
    if branch:
        dirty = git(cwd, "status", "--porcelain")
        mark = f"{fg(203)}*{RESET}" if dirty else ""
        parts.append(f"{fg(176)}{branch}{RESET}{mark}")

    name = model.get("display_name") or model.get("id") or "model"
    bits = [f"{fg(80)}{name}{RESET}"]
    summary = model.get("param_summary")
    if summary:
        bits.append(f"{DIM}{summary}{RESET}")
    if model.get("max_mode"):
        bits.append(f"{BOLD}{fg(215)}MAX{RESET}")
    parts.append(" ".join(bits))

    used = ctx.get("used_percentage")
    if used is not None:
        try:
            parts.append(bar(int(float(used))))
        except (TypeError, ValueError):
            pass

    wt = worktree.get("name")
    if wt:
        parts.append(f"{fg(180)}wt:{wt}{RESET}")

    session = payload.get("session_name")
    if session:
        parts.append(f"{DIM}{session}{RESET}")

    if payload.get("autorun"):
        parts.append(f"{fg(114)}auto{RESET}")

    line = f" {fg(238)}│{RESET} ".join(parts)
    width = payload.get("render_width_chars")
    if isinstance(width, int) and width > 8 and vis(line) > width:
        # Keep the rightmost (model / ctx) bits; drop session then path extras.
        while vis(line) > width and len(parts) > 2:
            parts.pop()
            line = f" {fg(238)}│{RESET} ".join(parts)

    sys.stdout.write(line)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
