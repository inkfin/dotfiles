"""Command-line entry: TUI by default, plus non-interactive subcommands."""

from __future__ import annotations

import argparse
import sys
from typing import List, Optional

from . import AppError, __version__, engine, log, registry, shims, util


def cmd_tui(_args: argparse.Namespace) -> int:
    log.log(f"starting: python={sys.version.split()[0]} executable={sys.executable}")
    try:
        tools = registry.load_tools()
    except AppError as e:
        log.error(f"cannot load catalog: {e}")
        print(f"apptools: {e}")
        return 1
    state = registry.sync_state(registry.load_state(), tools)
    log.log(f"catalog: {len(tools)} tools on {engine.platform()}")
    from . import tui

    return tui.run(tools, state)


def cmd_list(_args: argparse.Namespace) -> int:
    tools = registry.load_tools()
    state = registry.sync_state(registry.load_state(), tools)
    shown = [t for t in tools if engine.platform_available(t)]
    hidden = len(tools) - len(shown)
    print(f"{'':4}{'tool':<20}{'method':<10}{'status':<12}version")
    print("-" * 60)
    for t in shown:
        entry = state["tools"].get(t.name, {})
        installed, method, version = engine.probe(t, entry)
        enabled = entry.get("enabled", t.enabled)
        mark = "[x]" if enabled else "[ ]"
        status = "installed" if installed else ("disabled" if not enabled else "missing")
        print(f"{mark:<4}{t.name:<20}{(method or '-'):<10}{status:<12}{version or ''}")
    if hidden:
        print(f"\n{hidden} tool(s) have no recipe on {engine.platform()} (hidden)")
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
    print("deps: none (stdlib only)")
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
    print(f"log: {log.log_path()}")
    print(f"platform: {util.os_name()}")
    return 0 if ok else 1


def cmd_version(_args: argparse.Namespace) -> int:
    print(f"apptools {__version__}")
    return 0


_HELP_TEXT = """\
apptools — per-machine third-party tool manager (Python 3.8+, stdlib only)

WHAT IT DOES
  A tool catalog is declared in ~/.config/apptools/config.py as a TOOLS list.
  Each tool maps your OS to install recipes (archive/file/git/shell). Tools
  with several install strategies expose them as "methods" (e.g. neovim:
  download to ~/.local OR via brew).

  Per-machine selection is tracked in ~/.local/state/apptools/state.json:
    enabled   = "manage this tool on this machine" (the ✓ / ✗ toggle)
    installed = whether the tool is present (detected live)

  Installed tools get shims in ~/.local/bin, which is prepended to PATH so
  they override system packages.

THE MODEL
  * space        toggle one tool's "managed" flag
  * t            toggle all tools (platform-relevant) on/off
  * s (sync)     install missing + update installed, for ALL enabled tools
  * c (clean)    uninstall tools that are installed but NOT enabled
  * i / u / d    install / update / uninstall the SELECTED tool
  * m            cycle the install method of the selected tool

TUI KEYS
  space toggle   t toggle all   i install   u update   d uninstall
  m method   s sync   c clean   r rescan   / filter   ? help   q quit
  navigation: arrows, j/k, gg/G, pageup/pagedown, home/end

COMMANDS
  apptools                      launch the interactive TUI
  apptools list                 table of tools with status
  apptools status               summary of enabled/installed counts
  apptools install <name...|all>  install specific tools (or all missing)
  apptools update <name...|all>   update specific tools (or all installed)
  apptools uninstall <name...>    uninstall specific tools
  apptools apply                install all enabled-but-missing tools
  apptools sync                 install missing + update installed (enabled)
  apptools clean                uninstall installed-but-not-enabled + orphans
  apptools doctor               diagnose environment, print paths
  apptools version              print version

FILES
  ~/.config/apptools/config.py     the tool catalog (edit to add/remove tools)
  ~/.local/state/apptools/state.json  per-machine state (do not edit by hand)
  ~/.local/state/apptools/apptools.log  diagnostic log (APPPTOOLS_LOG to override)

CONFIG EXAMPLE (~/.config/apptools/config.py)
  from apptools import Tool, Method, Archive, File, Git, Shell
  TOOLS = [
      Tool(
          name="glsl_analyzer", desc="GLSL language server", group="lsp",
          sources={
              "windows": Archive("https://.../x86_64-windows.zip", strip=1, pick="bin/glsl_analyzer.exe"),
              "darwin":  Archive("https://.../aarch64-macos.zip",  strip=1, pick="bin/glsl_analyzer"),
              "linux":   Archive("https://.../x86_64-linux-musl.zip", strip=1, pick="bin/glsl_analyzer"),
          },
      ),
  ]
  Methods (multiple install strategies per tool):
  Tool(name="neovim", methods={
      "local": Method(sources={...archive into ~/.local/neovim, bin=...}),
      "brew":  Method(sources={...Shell("brew install neovim", ...)}),
  })

ENV
  APPPTOOLS_CONFIG   override catalog path
  APPPTOOLS_LOG      override log file path
  APPPTOOLS_LOG_LEVEL  debug|info|warning|error (default info)
"""


def cmd_help(_args: argparse.Namespace) -> int:
    print(_HELP_TEXT)
    return 0


def main(argv: Optional[List[str]] = None) -> int:
    argv = list(sys.argv[1:]) if argv is None else list(argv)
    if not argv or argv[0] == "tui":
        try:
            return cmd_tui(argparse.Namespace())
        except AppError as e:
            log.error(f"{e}")
            print(f"apptools: {e}", file=sys.stderr)
            return 1
        except Exception:
            log.exception("startup")
            print("apptools: startup failed (see log: " + str(log.log_path()) + ")", file=sys.stderr)
            return 1
    parser = argparse.ArgumentParser(
        prog="apptools",
        description="per-machine third-party tool manager (stdlib only, no deps)",
        epilog="Run `apptools help` for the full guide.",
    )
    sub = parser.add_subparsers(dest="cmd", required=True)
    sub.add_parser("help", help="print the full user guide")
    sub.add_parser("list", help="table of tools with status / method / version")
    sub.add_parser("status", help="summary of enabled/installed counts")
    p = sub.add_parser("install", help="install specific tools or all missing")
    p.add_argument("names", nargs="+", help="tool names, or the literal `all`")
    p = sub.add_parser("update", help="update specific tools or all installed")
    p.add_argument("names", nargs="+", help="tool names, or the literal `all`")
    p = sub.add_parser("uninstall", help="uninstall specific tools")
    p.add_argument("names", nargs="+", help="tool names")
    sub.add_parser("apply", help="install all enabled-but-missing tools")
    sub.add_parser("sync", help="for enabled tools: install missing + update installed")
    p = sub.add_parser("clean", help="uninstall installed-but-not-enabled tools and orphans")
    p.add_argument("--yes", action="store_true", help="skip the confirmation prompt")
    sub.add_parser("doctor", help="diagnose environment and print all paths")
    sub.add_parser("version", help="print version")
    args = parser.parse_args(argv)
    handlers = {
        "help": cmd_help,
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
        log.error(f"{e}")
        print(f"apptools: {e}", file=sys.stderr)
        return 1
    except Exception:
        log.exception(f"command '{args.cmd}'")
        print("apptools: unexpected error (see log: " + str(log.log_path()) + ")", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
