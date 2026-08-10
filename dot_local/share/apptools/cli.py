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


def _status_text(enabled: bool, status: str) -> str:
    """Show install state; prefix with off: when not managed."""
    if status == "installed":
        core = "installed"
    elif status == "external":
        core = "external"
    else:
        core = "missing"
    if not enabled:
        return f"off/{core}"
    return core



def cmd_list(args: argparse.Namespace) -> int:
    tools = registry.load_tools()
    state = registry.sync_state(registry.load_state(), tools)
    shown = [t for t in tools if engine.platform_available(t)]
    hidden = len(tools) - len(shown)

    view = getattr(args, "view", None) or "all"
    group_filter = getattr(args, "group", None)
    name_filter = (getattr(args, "filter", None) or "").strip().lower()

    # group headers when not plain
    by_group: dict = {}
    order: List[str] = []
    for t in shown:
        if group_filter and (t.group or "") != group_filter:
            continue
        if name_filter:
            blob = f"{t.name} {t.group or ''} {t.desc or ''}".lower()
            if name_filter not in blob:
                continue

        entry = state["tools"].get(t.name, {})
        status, method, version = engine.probe(t, entry)
        enabled = entry.get("enabled", t.enabled)
        if view == "managed" and not enabled:
            continue
        if view == "missing" and not (enabled and status == "missing"):
            continue
        if view == "installed" and status != "installed":
            continue
        if view == "external" and status != "external":
            continue
        g = t.group or "other"
        if g not in by_group:
            by_group[g] = []
            order.append(g)
        by_group[g].append((t, entry, status, method, version, enabled))

    print(f"{'':4}{'tool':<22}{'method':<10}{'status':<22}version")
    print("─" * 72)
    total_shown = 0
    for g in order:
        print(f"{'':4}{g}")
        for t, entry, status, method, version, enabled in by_group[g]:
            mark = "[x]" if enabled else "[ ]"
            st = _status_text(enabled, status)
            print(f"{mark:<4}{t.name:<22}{(method or '-'):<10}{st:<22}{version or ''}")
            total_shown += 1
    if total_shown == 0:
        print("(no tools match)")
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
    managed = missing = apptools_ok = external = unmanaged_present = absent = 0
    available = 0
    for t in tools:
        if not engine.platform_available(t):
            continue
        available += 1
        entry = state["tools"].get(t.name, {})
        status, _, _ = engine.probe(t, entry)
        is_enabled = entry.get("enabled", t.enabled)
        if is_enabled:
            managed += 1
            if status == "missing":
                missing += 1
        if status == "installed":
            apptools_ok += 1
            if not is_enabled:
                unmanaged_present += 1
        elif status == "external":
            external += 1
            if not is_enabled:
                unmanaged_present += 1
        elif not is_enabled:
            absent += 1
    print(f"platform: {plat}")
    print(f"tools in catalog: {len(tools)}  (available here: {available})")
    print(
        f"managed: {managed}   apptools-installed: {apptools_ok}   "
        f"external: {external}   missing (managed): {missing}"
    )
    print(f"unmanaged but present: {unmanaged_present}   absent: {absent}")

    orphans = registry.orphans(state, tools)
    if orphans:
        print(f"orphans: {', '.join(orphans)}")
    if missing:
        names = []
        for t in tools:
            entry = state["tools"].get(t.name, {})
            if entry.get("enabled", t.enabled) and engine.probe(t, entry)[0] == "missing":
                names.append(t.name)
        print(f"to install: {', '.join(names)}")
        print("hint: apptools apply")
    return 0


def cmd_show(args: argparse.Namespace) -> int:
    tools = registry.load_tools()
    state = registry.sync_state(registry.load_state(), tools)
    by_name = {t.name: t for t in tools}
    tool = by_name.get(args.name)
    if tool is None:
        print(f"apptools: unknown tool: {args.name}", file=sys.stderr)
        # suggest close names
        close = [n for n in by_name if args.name.lower() in n.lower()]
        if close:
            print(f"did you mean: {', '.join(close[:5])}", file=sys.stderr)
        return 1
    entry = state["tools"].get(tool.name, {})
    status, method, version = engine.probe(tool, entry)
    enabled = entry.get("enabled", tool.enabled)
    plat = engine.platform()
    print(f"name:     {tool.name}")
    print(f"desc:     {tool.desc}")
    print(f"group:    {tool.group or '—'}")
    print(f"managed:  {'yes' if enabled else 'no'}")
    print(f"status:   {_status_text(enabled, status)}")
    print(f"method:   {method or '—'}")
    if version:
        print(f"version:  {version}")
    if entry.get("updated_at"):
        print(f"updated:  {entry['updated_at']}")
    if entry.get("managed_dir"):
        print(f"dir:      {entry['managed_dir']}")
    if entry.get("url"):
        print(f"url:      {entry['url']}")
    if entry.get("shims"):
        print(f"shims:    {', '.join(entry['shims'])}")
    print("methods:")
    from . import Archive, File, Git, Shell

    for mname, mobj in engine.available_methods(tool, plat):
        recipe = mobj.sources[plat]
        mark = "*" if mname == method else " "
        if isinstance(recipe, Shell):
            summary = recipe.install
        elif isinstance(recipe, Git):
            summary = f"git {recipe.url}"
        elif isinstance(recipe, File):
            summary = recipe.url
        elif isinstance(recipe, Archive):
            summary = f"archive {recipe.url}" + (f" pick={recipe.pick}" if recipe.pick else "")
        else:
            summary = type(recipe).__name__
        print(f"  {mark} {mname}: {summary}")
    if not engine.platform_available(tool):
        print(f"(no recipe on {plat})")
    return 0


def _resolve_names(names: List[str], tools: List[Tool]) -> List:
    by_name = {t.name: t for t in tools}
    if names == ["all"]:
        return list(tools)
    out = []
    for name in names:
        tool = by_name.get(name)
        if tool is None:
            close = [n for n in by_name if name.lower() in n.lower()]
            msg = f"apptools: unknown tool: {name}"
            if close:
                msg += f" (did you mean: {', '.join(close[:5])})"
            raise AppError(msg)
        out.append(tool)
    return out


def cmd_install(args: argparse.Namespace) -> int:
    tools = registry.load_tools()
    state = registry.sync_state(registry.load_state(), tools)
    if args.names == ["all"]:
        targets = [
            t for t in tools
            if engine.platform_available(t)
            and engine.probe(t, state["tools"].get(t.name, {}))[0] != "installed"
        ]
        if not targets:
            print("apptools: everything already installed")
            return 0
    else:
        targets = _resolve_names(args.names, tools)
    errors = 0
    for t in targets:
        try:
            engine.install(t, state, method_name=getattr(args, "method", None), log=print)
        except AppError as e:
            errors += 1
            print(f"apptools: {e}", file=sys.stderr)
    return 1 if errors else 0


def cmd_update(args: argparse.Namespace) -> int:
    tools = registry.load_tools()
    state = registry.sync_state(registry.load_state(), tools)
    if args.names == ["all"]:
        targets = [
            t for t in tools
            if engine.platform_available(t)
            and engine.probe(t, state["tools"].get(t.name, {}))[0] != "missing"
        ]
    else:
        targets = _resolve_names(args.names, tools)
    if not targets:
        print("apptools: nothing to update")
        return 0
    errors = 0
    for t in targets:
        try:
            engine.update(t, state, log=print)
        except AppError as e:
            errors += 1
            print(f"apptools: {e}", file=sys.stderr)
    return 1 if errors else 0


def cmd_uninstall(args: argparse.Namespace) -> int:
    tools = registry.load_tools()
    state = registry.load_state()
    by_name = {t.name: t for t in tools}
    errors = 0
    for name in args.names:
        if name not in by_name and name not in state.get("tools", {}):
            print(f"apptools: unknown tool: {name}", file=sys.stderr)
            errors += 1
            continue
        try:
            engine.uninstall(name, state, tools, log=print)
        except AppError as e:
            errors += 1
            print(f"apptools: {e}", file=sys.stderr)
    return 1 if errors else 0


def cmd_enable(args: argparse.Namespace) -> int:
    tools = registry.load_tools()
    state = registry.sync_state(registry.load_state(), tools)
    targets = _resolve_names(args.names, tools)
    for t in targets:
        entry = state["tools"].setdefault(t.name, {"enabled": False, "installed": False})
        entry["enabled"] = True
        if getattr(args, "method", None):
            entry["method"] = args.method
        print(f"apptools: enabled {t.name}")
    registry.save_state(state)
    if getattr(args, "apply", False):
        return 1 if engine.apply_enabled(state, tools, log=print) else 0
    return 0


def cmd_disable(args: argparse.Namespace) -> int:
    tools = registry.load_tools()
    state = registry.sync_state(registry.load_state(), tools)
    targets = _resolve_names(args.names, tools)
    for t in targets:
        entry = state["tools"].setdefault(t.name, {"enabled": False, "installed": False})
        entry["enabled"] = False
        print(f"apptools: disabled {t.name}")
    registry.save_state(state)
    return 0


def cmd_apply(_args: argparse.Namespace) -> int:
    tools = registry.load_tools()
    state = registry.sync_state(registry.load_state(), tools)
    return 1 if engine.apply_enabled(state, tools, log=print) else 0


def cmd_sync(_args: argparse.Namespace) -> int:
    tools = registry.load_tools()
    state = registry.sync_state(registry.load_state(), tools)
    return 1 if engine.sync_enabled(state, tools, log=print) else 0


def cmd_clean(args: argparse.Namespace) -> int:
    tools = registry.load_tools()
    state = registry.load_state()
    targets = []
    for t in tools:
        entry = state["tools"].get(t.name, {})
        if entry.get("enabled", t.enabled):
            continue
        if engine.probe(t, entry)[0] == "installed" and entry.get("recipe_kind"):
            targets.append(t.name)
    targets += [o for o in registry.orphans(state, tools) if o not in targets]
    if not targets:
        print("apptools: nothing to clean")
        return 0
    print(f"apptools: will uninstall: {', '.join(targets)}")
    if not args.yes:
        try:
            answer = input("proceed? [y/N] ").strip().lower()
        except EOFError:
            answer = ""
        if answer not in ("y", "yes"):
            print("apptools: aborted")
            return 0
    errors = 0
    for name in targets:
        try:
            engine.uninstall(name, state, tools, log=print)
        except AppError as e:
            errors += 1
            print(f"apptools: {e}", file=sys.stderr)
    return 1 if errors else 0


def cmd_doctor(_args: argparse.Namespace) -> int:
    ok = True
    print(f"python:   {sys.version.split()[0]} ({sys.executable})")
    print("deps:     none (stdlib only)")
    print(f"version:  {__version__}")
    cfg = registry.config_path()
    print(f"config:   {cfg} ({'OK' if cfg.exists() else 'MISSING'})")
    tools = []
    if cfg.exists():
        try:
            tools = registry.load_tools()
            print(f"catalog:  {len(tools)} tools")
        except AppError as e:
            print(f"catalog:  ERROR {e}")
            ok = False
    else:
        ok = False
    bdir = shims.bin_dir()
    print(f"bin dir:  {bdir} ({'exists' if bdir.is_dir() else 'missing'})")
    on_path = False
    try:
        import os
        from pathlib import Path as _P

        path_env = os.environ.get("PATH", "")
        parts = [p for p in path_env.split(os.pathsep) if p]
        bdir_s = str(bdir)
        bdir_r = str(bdir.resolve())
        on_path = any(p == bdir_s or str(_P(p).resolve()) == bdir_r for p in parts)
    except Exception:
        pass
    print(f"on PATH:  {'yes' if on_path else 'NO — add ~/.local/bin to PATH'}")
    if not on_path:
        ok = False

    print(f"state:    {registry.state_path()}")
    print(f"log:      {log.log_path()}")
    print(f"platform: {util.os_name()}")

    # package managers
    for pm, cmd in (("scoop", "scoop"), ("brew", "brew"), ("git", "git")):
        which = util.which(cmd)
        print(f"{pm + ':':<10}{which or 'not found'}")

    if tools:
        state = registry.sync_state(registry.load_state(), tools)
        broken = []
        for t in tools:
            if not engine.platform_available(t):
                continue
            entry = state["tools"].get(t.name, {})
            if not entry.get("installed") and not entry.get("placed") and not entry.get("shims"):
                continue
            status, _, _ = engine.probe(t, entry)
            if entry.get("recipe_kind") and status == "missing":
                broken.append(t.name)
        if broken:
            print(f"stale state (marked installed, probe missing): {', '.join(broken)}")
            print("hint: apptools uninstall <name>  or  edit state.json")
        orphans = registry.orphans(state, tools)
        if orphans:
            print(f"orphans:  {', '.join(orphans)}")
            print("hint: apptools clean")

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
    enabled   = "manage this tool on this machine" (the ✓ toggle)
    installed = whether the tool is present (detected live)

  Status of a tool is detected live, not from the catalog method:
    installed             = installed by apptools (~/.local shim/dir, or the
                            configured scoop/brew install)
    installed (external)  = the binary is on PATH but was NOT installed by
                            apptools (e.g. via apt/pacman, or a manual path)
    missing               = not found

  sync (s) installs the apptools copy (into ~/.local) for any enabled tool
  that isn't apptools-managed yet, including externally-present ones, so
  ~/.local takes PATH precedence. clean (c) only ever removes what apptools
  itself installed.

  Installed tools get shims in ~/.local/bin, which is prepended to PATH so
  they override system packages.

THE MODEL
  * space        toggle one tool's "managed" flag
  * t            toggle all visible tools on/off
  * a (apply)    install all enabled-but-missing tools
  * s (sync)     install missing + update installed, for ALL enabled tools
  * c (clean)    uninstall tools that are installed but NOT enabled
  * i / u / d    install / update / uninstall the SELECTED tool
  * m            cycle the install method of the selected tool
  * f            cycle view filter (all/managed/missing/installed/external)
  * /            filter by name, group, or description
  * z            collapse / expand all groups

TUI KEYS
  space toggle   t toggle visible   i install   u update   d uninstall
  m method   a apply   s sync   c clean   r rescan
  f view   / filter   z groups   ? help   q quit
  navigation: arrows, j/k, h/l (fold), gg/G, pageup/pagedown, home/end

COMMANDS
  apptools                         launch the interactive TUI
  apptools list [--view V] [-g G]  table of tools with status
  apptools status                  summary of enabled/installed counts
  apptools show <name>             detail one tool
  apptools enable <name...> [--apply]   mark managed (optionally install)
  apptools disable <name...>       mark unmanaged
  apptools install <name...|all> [--method M]
  apptools update <name...|all>
  apptools uninstall <name...>
  apptools apply                   install all enabled-but-missing tools
  apptools sync                    install missing + update installed (enabled)
  apptools clean [--yes]           uninstall installed-but-not-enabled + orphans
  apptools doctor                  diagnose environment, print paths
  apptools version                 print version

FILES
  ~/.config/apptools/config.py        the tool catalog (edit to add/remove tools)
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
      "download": Method(sources={...archive into ~/.local/neovim, bin=...}),
      "brew":     Method(sources={...Shell("brew install neovim", ...)}),
  })

ENV
  APPPTOOLS_CONFIG     override catalog path
  APPPTOOLS_LOG        override log file path
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
    p = sub.add_parser("list", help="table of tools with status / method / version")
    p.add_argument("--view", choices=["all", "managed", "missing", "installed", "external"], default="all")
    p.add_argument("-g", "--group", default=None, help="only show this group")
    p.add_argument("-f", "--filter", default=None, help="substring filter on name/group")
    sub.add_parser("status", help="summary of enabled/installed counts")
    p = sub.add_parser("show", help="show detail for one tool")
    p.add_argument("name", help="tool name")
    p = sub.add_parser("enable", help="mark tools as managed on this machine")
    p.add_argument("names", nargs="+", help="tool names")
    p.add_argument("--method", default=None, help="pin install method")
    p.add_argument("--apply", action="store_true", help="also install if missing")
    p = sub.add_parser("disable", help="mark tools as unmanaged")
    p.add_argument("names", nargs="+", help="tool names")
    p = sub.add_parser("install", help="install specific tools or all missing")
    p.add_argument("names", nargs="+", help="tool names, or the literal `all`")
    p.add_argument("--method", default=None, help="override install method")
    p = sub.add_parser("update", help="update specific tools or all installed")
    p.add_argument("names", nargs="+", help="tool names, or the literal `all`")
    p = sub.add_parser("uninstall", help="uninstall specific tools")
    p.add_argument("names", nargs="+", help="tool names")
    sub.add_parser("apply", help="install all enabled-but-missing tools")
    sub.add_parser("sync", help="for enabled tools: install missing + update installed")
    p = sub.add_parser("clean", help="uninstall installed-but-not-enabled tools and orphans")
    p.add_argument("--yes", "-y", action="store_true", help="skip the confirmation prompt")
    sub.add_parser("doctor", help="diagnose environment and print all paths")
    sub.add_parser("version", help="print version")
    args = parser.parse_args(argv)
    handlers = {
        "help": cmd_help,
        "list": cmd_list,
        "status": cmd_status,
        "show": cmd_show,
        "enable": cmd_enable,
        "disable": cmd_disable,
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
