"""Command-line entry: TUI by default, plus non-interactive subcommands."""

from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path
from typing import List, Optional

from . import AppError, __version__, engine, registry, shims, util

_VENV_DIR = "~/.local/state/apptools/venv"


def _venv_path() -> Path:
    env = os.environ.get("APPPTOOLS_VENV")
    return Path(env) if env else util.expand(_VENV_DIR)


def _venv_python() -> Path:
    if sys.platform.startswith("win"):
        return _venv_path() / "Scripts" / "python.exe"
    return _venv_path() / "bin" / "python"


def _in_venv() -> bool:
    try:
        return os.path.abspath(sys.prefix) == os.path.abspath(str(_venv_path()))
    except Exception:
        return False


def ensure_venv(log=print) -> str:
    """Create the apptools venv (isolated from system packages) if missing."""
    py = _venv_python()
    if py.exists():
        return str(py)
    _venv_path().parent.mkdir(parents=True, exist_ok=True)
    log("apptools: creating virtualenv for TUI dependencies...")
    util.run([sys.executable, "-m", "venv", str(_venv_path())], log=log, check=True)
    log("apptools: installing 'textual' into the virtualenv...")
    util.run([str(py), "-m", "pip", "install", "textual"], log=log, check=True)
    return str(py)


def cmd_tui(_args: argparse.Namespace) -> int:
    tools = registry.load_tools()
    state = registry.sync_state(registry.load_state(), tools)
    if not _in_venv():
        try:
            venv_py = ensure_venv()
        except AppError as e:
            print(f"apptools: {e}")
            print("hint: install a virtualenv first, e.g. `python -m venv <path>`")
            return 1
        if sys.executable != venv_py:
            os.execv(venv_py, [venv_py, "-m", "apptools", "tui"])
    try:
        from . import tui
    except ImportError:
        print("apptools: 'textual' is missing in the apptools virtualenv.")
        print(f"hint: remove {_venv_path()} and run `apptools` again")
        return 1
    return tui.run(tools, state)


def cmd_list(_args: argparse.Namespace) -> int:
    tools = registry.load_tools()
    state = registry.sync_state(registry.load_state(), tools)
    print(f"{'':4}{'tool':<20}{'method':<10}{'status':<12}version")
    print("-" * 60)
    for t in tools:
        entry = state["tools"].get(t.name, {})
        installed, method, version = engine.probe(t, entry)
        enabled = entry.get("enabled", t.enabled)
        mark = "[x]" if enabled else "[ ]"
        status = "installed" if installed else ("off" if not enabled else "missing")
        print(f"{mark:<4}{t.name:<20}{(method or '-'):<10}{status:<12}{version or ''}")
    orphans = registry.orphans(state, tools)
    if orphans:
        print(f"\norphans (removed from catalog): {', '.join(orphans)}")
    return 0


def cmd_status(_args: argparse.Namespace) -> int:
    tools = registry.load_tools()
    state = registry.sync_state(registry.load_state(), tools)
    plat = engine.platform()
    installed = enabled = missing = off = 0
    for t in tools:
        entry = state["tools"].get(t.name, {})
        is_installed, _, _ = engine.probe(t, entry)
        is_enabled = entry.get("enabled", t.enabled)
        installed += int(is_installed)
        enabled += int(is_enabled)
        if not is_enabled and not is_installed:
            off += 1
        if is_enabled and not is_installed:
            missing += 1
    print(f"platform: {plat}")
    print(f"tools in catalog: {len(tools)}")
    print(f"enabled: {enabled}   installed: {installed}   missing (enabled): {missing}   disabled: {off}")
    orphans = registry.orphans(state, tools)
    if orphans:
        print(f"orphans: {', '.join(orphans)}")
    return 0


def cmd_install(args: argparse.Namespace) -> int:
    tools = registry.load_tools()
    state = registry.sync_state(registry.load_state(), tools)
    if args.names == ["all"]:
        targets = [t for t in tools if not state["tools"].get(t.name, {}).get("installed")]
        if not targets:
            print("apptools: everything already installed")
            return 0
        for t in targets:
            engine.install(t, state, log=print)
        return 0
    by_name = {t.name: t for t in tools}
    for name in args.names:
        tool = by_name.get(name)
        if tool is None:
            print(f"apptools: unknown tool: {name}")
            return 1
        engine.install(tool, state, log=print)
    return 0


def cmd_update(args: argparse.Namespace) -> int:
    tools = registry.load_tools()
    state = registry.sync_state(registry.load_state(), tools)
    by_name = {t.name: t for t in tools}
    if args.names == ["all"]:
        for t in tools:
            if state["tools"].get(t.name, {}).get("installed"):
                engine.update(t, state, log=print)
        return 0
    for name in args.names:
        tool = by_name.get(name)
        if tool is None:
            print(f"apptools: unknown tool: {name}")
            return 1
        engine.update(tool, state, log=print)
    return 0


def cmd_uninstall(args: argparse.Namespace) -> int:
    tools = registry.load_tools()
    state = registry.load_state()
    for name in args.names:
        engine.uninstall(name, state, tools, log=print)
    return 0


def cmd_apply(_args: argparse.Namespace) -> int:
    tools = registry.load_tools()
    state = registry.sync_state(registry.load_state(), tools)
    engine.apply_enabled(state, tools, log=print)
    return 0


def cmd_sync(_args: argparse.Namespace) -> int:
    tools = registry.load_tools()
    state = registry.sync_state(registry.load_state(), tools)
    engine.sync_enabled(state, tools, log=print)
    return 0


def cmd_clean(args: argparse.Namespace) -> int:
    tools = registry.load_tools()
    state = registry.load_state()
    targets = [
        t.name
        for t in tools
        if state["tools"].get(t.name, {}).get("installed") and not state["tools"].get(t.name, {}).get("enabled", t.enabled)
    ]
    targets += registry.orphans(state, tools)
    if not targets:
        print("apptools: nothing to clean")
        return 0
    print(f"apptools: will uninstall: {', '.join(targets)}")
    if not args.yes:
        answer = input("proceed? [y/N] ").strip().lower()
        if answer not in ("y", "yes"):
            print("apptools: aborted")
            return 0
    for name in targets:
        engine.uninstall(name, state, tools, log=print)
    return 0


def cmd_doctor(_args: argparse.Namespace) -> int:
    ok = True
    print(f"python: {sys.version.split()[0]} ({sys.executable})")
    venv_py = _venv_python()
    if venv_py.exists():
        probe = util.run([str(venv_py), "-c", "import textual; print(textual.__version__)"], log=lambda _m: None)
        if probe.returncode == 0:
            print(f"venv: {_venv_path()} (textual {probe.stdout.strip()})")
        else:
            print(f"venv: {_venv_path()} (textual MISSING, reinstall by removing the venv)")
            ok = False
    else:
        print(f"venv: {_venv_path()} (missing; created on first TUI run)")
    cfg = registry.config_path()
    print(f"config: {cfg} ({'OK' if cfg.exists() else 'MISSING'})")
    if cfg.exists():
        try:
            tools = registry.load_tools()
            print(f"catalog: {len(tools)} tools")
        except AppError as e:
            print(f"catalog: ERROR {e}")
            ok = False
    bdir = shims.bin_dir()
    print(f"bin dir: {bdir} ({'exists' if bdir.is_dir() else 'missing'})")
    print(f"state: {registry.state_path()}")
    print(f"platform: {util.os_name()}")
    return 0 if ok else 1


def cmd_version(_args: argparse.Namespace) -> int:
    print(f"apptools {__version__}")
    return 0


def main(argv: Optional[List[str]] = None) -> int:
    argv = list(sys.argv[1:]) if argv is None else list(argv)
    if not argv or argv[0] == "tui":
        return cmd_tui(argparse.Namespace())
    parser = argparse.ArgumentParser(prog="apptools", description="per-machine third-party tool manager")
    sub = parser.add_subparsers(dest="cmd", required=True)
    sub.add_parser("list", help="list catalog with per-machine state")
    sub.add_parser("status", help="summary of enabled/installed tools")
    p = sub.add_parser("install", help="install tools (all | <name>...)")
    p.add_argument("names", nargs="+")
    p = sub.add_parser("update", help="update tools (all | <name>...)")
    p.add_argument("names", nargs="+")
    p = sub.add_parser("uninstall", help="uninstall tools")
    p.add_argument("names", nargs="+")
    sub.add_parser("apply", help="install all enabled-but-missing tools")
    sub.add_parser("sync", help="install missing + update installed, for enabled tools")
    p = sub.add_parser("clean", help="uninstall installed-but-disabled tools and orphans")
    p.add_argument("--yes", action="store_true", help="skip confirmation")
    sub.add_parser("doctor", help="check environment")
    sub.add_parser("version", help="print version")
    args = parser.parse_args(argv)
    handlers = {
        "list": cmd_list,
        "status": cmd_status,
        "install": cmd_install,
        "update": cmd_update,
        "uninstall": cmd_uninstall,
        "apply": cmd_apply,
        "sync": cmd_sync,
        "clean": cmd_clean,
        "doctor": cmd_doctor,
        "version": cmd_version,
    }
    try:
        return handlers[args.cmd](args)
    except AppError as e:
        print(f"apptools: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
