"""Minimal file logging for apptools (diagnose startup/TUI crashes).

Log lines go to ~/.local/state/apptools/apptools.log (override with
APPPTOOLS_LOG). Level is controlled by APPPTOOLS_LOG_LEVEL
(debug/info/warning/error, default info).
"""

from __future__ import annotations

import os
import sys
import traceback
from datetime import datetime
from pathlib import Path
from typing import Optional

_LEVELS = {"debug": 10, "info": 20, "warning": 30, "error": 40}


def log_path() -> Path:
    env = os.environ.get("APPPTOOLS_LOG")
    if env:
        return Path(env)
    return Path(os.path.expandvars(os.path.expanduser("~/.local/state/apptools/apptools.log")))


def _level() -> int:
    return _LEVELS.get(os.environ.get("APPPTOOLS_LOG_LEVEL", "info").strip().lower(), 20)


def _write(msg: str) -> None:
    try:
        p = log_path()
        p.parent.mkdir(parents=True, exist_ok=True)
        with open(p, "a", encoding="utf-8") as fh:
            fh.write(f"{datetime.now().isoformat(timespec='seconds')} {msg}\n")
    except Exception:
        pass


def log(msg: str, level: str = "info") -> None:
    if _LEVELS.get(level.lower(), 20) >= _level():
        _write(f"[{level.upper()}] {msg}")


def error(msg: str) -> None:
    _write(f"[ERROR] {msg}")


def exception(context: str = "") -> None:
    tb = traceback.format_exc().rstrip() or "no traceback available"
    if context:
        _write(f"[ERROR] exception during {context}:\n{tb}")
    else:
        _write(f"[ERROR] {tb}")
