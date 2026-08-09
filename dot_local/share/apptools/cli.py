"""Command-line entry: TUI by default, plus non-interactive subcommands."""

from __future__ import annotations

import argparse
import sys
from typing import List

from . import AppError, __version__, engine, registry, shims, util


def _bootstrap_textual() -> bool:
    try:
        import textual  # noqa: F401

        return True
    except ImportError:
        pass
    print("apptools: 'textual' is required for the TUI; installing it now...")
    rc = util.run([sys.executable, "-m", "pip", "install", "--user", "textual"], log=print)
    if rc.returncode != 0:
        print("apptools: failed to install textual; use the CLI subcommands instead")
        return False
    return True


def cmd_tui(_args: argparse.Namespace) -> int:
    tools = registry.load_tools()
    state = registry.sync_state(registry.load_state(), tools)
    if not _bootstrap_textual():
        return 1
    from . import tui

    tui.run(tools, state)
    return 0


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
    print(f"python: {sys.version.split()[0]}")
    try:
        import textual

        print(f"textual: {textual.__version__}")
    except ImportError:
        print("textual: MISSING (pip install --user textual for the TUI)")
        ok = False
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


def main(argv: List[str] | None = None) -> int:
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
