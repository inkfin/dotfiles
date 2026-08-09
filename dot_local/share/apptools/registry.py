"""Load the tool catalog (config.py) and the per-machine state.json."""

from __future__ import annotations

import importlib.util
import json
import os
import sys
from pathlib import Path
from typing import List

from . import AppError, Tool, ensure_share_on_path


def config_path() -> Path:
    env = os.environ.get("APPPTOOLS_CONFIG")
    if env:
        return Path(env)
    return util_home_config()


def util_home_config() -> Path:
    from . import util

    return util.expand("~/.config/apptools/config.py")


def state_dir() -> Path:
    from . import util

    return util.expand("~/.local/state/apptools")


def state_path() -> Path:
    return state_dir() / "state.json"


def load_tools() -> List[Tool]:
    cfg = config_path()
    if not cfg.exists():
        raise AppError(f"catalog not found: {cfg}")
    ensure_share_on_path()
    if str(cfg.parent) not in sys.path:
        sys.path.insert(0, str(cfg.parent))
    spec = importlib.util.spec_from_file_location("apptools_user_config", cfg)
    if spec is None or spec.loader is None:
        raise AppError(f"cannot load catalog: {cfg}")
    mod = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = mod
    spec.loader.exec_module(mod)
    tools = getattr(mod, "TOOLS", None)
    if not isinstance(tools, list) or not tools:
        raise AppError("catalog must define a non-empty TOOLS list")
    names = [t.name for t in tools]
    if len(set(names)) != len(names):
        raise AppError(f"duplicate tool names in catalog: {[n for n in names if names.count(n) > 1]}")
    return tools


def empty_state() -> dict:
    return {"version": 1, "tools": {}}


def load_state() -> dict:
    p = state_path()
    if not p.exists():
        return empty_state()
    try:
        data = json.loads(p.read_text(encoding="utf-8"))
    except Exception as e:
        raise AppError(f"cannot parse state file {p}: {e}")
    data.setdefault("version", 1)
    data.setdefault("tools", {})
    return data


def save_state(state: dict) -> None:
    state_dir().mkdir(parents=True, exist_ok=True)
    state_path().write_text(json.dumps(state, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def sync_state(state: dict, tools: List[Tool]) -> dict:
    for t in tools:
        entry = state["tools"].setdefault(t.name, {"enabled": bool(t.enabled), "installed": False})
        entry.setdefault("enabled", bool(t.enabled))
        entry.setdefault("installed", False)
    return state


def orphans(state: dict, tools: List[Tool]) -> List[str]:
    known = {t.name for t in tools}
    return [name for name in state["tools"] if name not in known]
