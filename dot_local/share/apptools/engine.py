"""Install/uninstall/update/apply logic plus installed-state probing."""

from __future__ import annotations

import fnmatch
import shutil
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Callable, Dict, List, Optional, Tuple

from . import Archive, AppError, File, Git, Method, Shell, Tool, util, shims
from . import registry


def platform() -> str:
    return util.os_name()


def available_methods(tool: Tool, plat: str) -> List[Tuple[str, Method]]:
    return [(name, method) for name, method in tool.methods.items() if plat in method.sources]


def platform_available(tool: Tool, plat: Optional[str] = None) -> bool:
    return bool(available_methods(tool, plat or platform()))


def resolve(tool: Tool, method_name: Optional[str] = None) -> Tuple[str, Method, object]:
    plat = platform()
    avail = available_methods(tool, plat)
    if not avail:
        raise AppError(f"{tool.name}: no recipe for platform '{plat}'")
    names = [n for n, _ in avail]
    chosen = None
    if method_name and method_name in names:
        chosen = method_name
    elif tool.default_method and tool.default_method in names:
        chosen = tool.default_method
    else:
        chosen = "download" if "download" in names else names[0]
    method = dict(avail)[chosen]
    return chosen, method, method.sources[plat]


def _extract_into(tool: Tool, recipe: object, plat: str) -> Path:
    if isinstance(recipe, (Archive, File)):
        if isinstance(recipe, Archive) and recipe.pick:
            return util.expand(recipe.into or "~/.local/bin")
        if isinstance(recipe, File):
            return util.expand(recipe.into or "~/.local/bin")
        return util.expand(recipe.into or f"~/.local/{tool.name}")
    if isinstance(recipe, Git):
        return util.expand(recipe.into or f"~/.local/{tool.name}")
    return util.expand("~/.local/bin")


def _now() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def install(tool: Tool, state: dict, method_name: Optional[str] = None, dry_run: bool = False, log: Callable[[str], None] = print) -> None:
    plat = platform()
    chosen, method, recipe = resolve(tool, method_name)
    entry = registry.sync_state(state, [tool])["tools"][tool.name]
    # installing implies the user wants it managed on this machine
    entry["enabled"] = True
    log(f"apptools: install {tool.name} [{chosen}/{plat}]")

    if isinstance(recipe, Shell):
        if not dry_run:
            status, _, _ = probe(tool, entry)
            if status == "installed":
                log(f"apptools: {tool.name} is already installed, use `update`")
                entry["enabled"] = True
                registry.save_state(state)
                return
        cmd = recipe.install
        if dry_run:
            log(f"  (dry-run) {cmd}")
            return
        util.run(util.shell_command(cmd), log=log, check=True)
        entry.update(installed=True, method=chosen, recipe_kind="shell", updated_at=_now(), enabled=True)
        entry.pop("managed_dir", None)
        entry.pop("placed", None)
        entry.pop("shims", None)
        registry.save_state(state)
        log("  done.")
        return

    dest = _extract_into(tool, recipe, plat)

    if isinstance(recipe, Git):
        if dry_run:
            log(f"  (dry-run) git clone {recipe.url} -> {dest}")
            return
        if dest.exists():
            util.rmtree_retry(dest)
        dest.parent.mkdir(parents=True, exist_ok=True)
        cmd = ["git", "clone"]
        if recipe.depth:
            cmd += ["--depth", str(recipe.depth)]
        if recipe.branch:
            cmd += ["--branch", recipe.branch]
        cmd += [recipe.url, str(dest)]
        util.run(cmd, log=log, check=True)
        entry.update(
            installed=True,
            enabled=True,
            method=chosen,
            recipe_kind="git",
            url=recipe.url,
            managed_dir=str(dest),
            updated_at=_now(),
        )
        entry.pop("placed", None)
        entry.pop("shims", None)
        registry.save_state(state)
        log("  done.")
        return

    placed: List[str] = []
    shim_list: List[str] = []
    url = getattr(recipe, "url", None)

    if dry_run:
        log(f"  (dry-run) download {url}")
        log(f"  (dry-run) install into {dest}")
        return

    # wipe previous managed dir when reinstalling into a dedicated folder
    prev_dir = entry.get("managed_dir")
    if prev_dir:
        pd = util.expand(prev_dir).resolve()
        local = util.expand("~/.local").resolve()
        if str(pd).startswith(str(local)) and pd.exists() and pd != shims.bin_dir().resolve():
            try:
                util.rmtree_retry(pd)
            except AppError as e:
                log(f"  warning: could not clear old dir: {e}")

    with tempfile.TemporaryDirectory(prefix="apptools-") as td:
        tdir = Path(td)
        if isinstance(recipe, Archive):
            tmp = tdir / util.basename_from_url(url)
            util.download(url, tmp, progress=lambda done, total: log(f"  {_fmt_size(done)}/{_fmt_size(total) if total else '?'}"))
            if recipe.pick:
                xdir = tdir / "x"
                xdir.mkdir()
                util.extract(tmp, xdir)
                matches = util.find_files(xdir, recipe.pick)
                if not matches:
                    raise AppError(f"{tool.name}: no file matches pick '{recipe.pick}'")
                dest.mkdir(parents=True, exist_ok=True)
                for m in matches:
                    target = dest / m.name
                    shutil.copy2(m, target)
                    if recipe.executable and plat != "windows":
                        target.chmod(0o755)
                    placed.append(str(target))
            else:
                dest.mkdir(parents=True, exist_ok=True)
                util.extract(tmp, dest, strip=recipe.strip, include=recipe.include, exclude=recipe.exclude)
                placed = [str(p) for p in sorted(dest.rglob("*")) if p.is_file()]
        elif isinstance(recipe, File):
            name = recipe.name or util.basename_from_url(url)
            dest.mkdir(parents=True, exist_ok=True)
            target = dest / name
            util.download(url, target, progress=lambda done, total: log(f"  {_fmt_size(done)}/{_fmt_size(total) if total else '?'}"))
            if recipe.executable and plat != "windows":
                target.chmod(0o755)
            placed = [str(target)]
        else:
            raise AppError(f"{tool.name}: unsupported recipe {type(recipe).__name__}")

    # drop old shims before creating new ones
    shims.remove_shims(entry.get("shims") or [])

    if getattr(recipe, "bin", None):
        shim_list.append(str(shims.create_shim(recipe.bin, env=recipe.shim_env)))
    elif isinstance(recipe, File) and dest.resolve() != shims.bin_dir().resolve():
        shim_list.append(str(shims.create_shim(str(dest / (recipe.name or util.basename_from_url(url))))))
    elif isinstance(recipe, Archive) and recipe.pick and dest.resolve() == shims.bin_dir().resolve():
        # binary already landed in bin dir — nothing extra
        pass
    elif isinstance(recipe, Archive) and recipe.pick:
        for p in placed:
            try:
                shim_list.append(str(shims.create_shim(p)))
            except Exception as e:
                log(f"  warning: shim for {p}: {e}")

    entry.update(
        installed=True,
        enabled=True,
        method=chosen,
        recipe_kind=type(recipe).__name__.lower(),
        url=url,
        managed_dir=str(dest) if dest.resolve() != shims.bin_dir().resolve() else None,
        placed=placed,
        shims=shim_list,
        updated_at=_now(),
    )
    registry.save_state(state)
    log("  done.")


def _fmt_size(n: int) -> str:
    if n <= 0:
        return "0B"
    for unit in ("B", "K", "M", "G"):
        if n < 1024:
            return f"{n:.0f}{unit}" if unit == "B" else f"{n:.0f}{unit}"
        n /= 1024
    return f"{n:.0f}T"


def uninstall(name: str, state: dict, tools: List[Tool], log: Callable[[str], None] = print) -> None:
    entry = state["tools"].get(name)
    if not entry:
        log(f"apptools: {name} is not tracked")
        return
    by_name = {t.name: t for t in tools}
    tool = by_name.get(name)
    recipe = None
    if tool:
        try:
            _, method, recipe = resolve(tool, entry.get("method"))
            if isinstance(recipe, Shell) and recipe.uninstall:
                util.run(util.shell_command(recipe.uninstall), log=log, check=False)
        except AppError as e:
            log(f"apptools: {e}")
    shims.remove_shims(entry.get("shims", []))
    for f in entry.get("placed", []):
        p = util.expand(f)
        if p.is_file():
            p.unlink(missing_ok=True)
    md = entry.get("managed_dir")
    if md:
        d = util.expand(md).resolve()
        local = util.expand("~/.local").resolve()
        if str(d).startswith(str(local)) and d.exists():
            util.rmtree_retry(d)
    entry["installed"] = False
    entry.pop("shims", None)
    entry.pop("placed", None)
    entry.pop("managed_dir", None)
    entry.pop("version", None)
    registry.save_state(state)
    log(f"apptools: uninstalled {name}")


def update(tool: Tool, state: dict, log: Callable[[str], None] = print) -> None:
    entry = state["tools"].get(tool.name, {})
    status, _, _ = probe(tool, entry)
    if status == "missing":
        log(f"apptools: {tool.name} is not installed, run install first")
        return
    plat = platform()
    try:
        chosen, method, recipe = resolve(tool, entry.get("method"))
    except AppError as e:
        log(f"apptools: {e}")
        return
    log(f"apptools: update {tool.name} [{chosen}/{plat}]")
    if isinstance(recipe, Shell):
        cmd = recipe.update or recipe.install
        util.run(util.shell_command(cmd), log=log, check=True)
        entry["updated_at"] = _now()
        registry.save_state(state)
        log("  done.")
        return
    if isinstance(recipe, Git):
        d = util.expand(recipe.into or f"~/.local/{tool.name}")
        if (d / ".git").exists():
            proc = util.run(["git", "-C", str(d), "pull", "--ff-only"], log=log)
            if proc.returncode != 0:
                log("  pull failed, re-cloning")
                install(tool, state, method_name=chosen, log=log)
                return
            entry["updated_at"] = _now()
            registry.save_state(state)
            log("  done.")
            return
    install(tool, state, method_name=chosen, log=log)


def apply_enabled(state: dict, tools: List[Tool], log: Callable[[str], None] = print) -> int:
    """Install enabled-but-not-apptools-managed tools. Returns error count."""
    errors = 0
    n = 0
    for tool in tools:
        if not platform_available(tool):
            continue
        entry = state["tools"].get(tool.name, {})
        if not entry.get("enabled", tool.enabled):
            continue
        status, _, _ = probe(tool, entry)
        if status != "installed":
            n += 1
            try:
                install(tool, state, log=log)
            except AppError as e:
                errors += 1
                log(f"apptools: {e}")
    if n == 0:
        log("apptools: nothing to apply")
    elif errors:
        log(f"apptools: apply finished with {errors} error(s)")
    return errors


def sync_enabled(state: dict, tools: List[Tool], log: Callable[[str], None] = print) -> int:
    """Install missing + update installed for all enabled tools. Returns error count."""
    errors = 0
    n = 0
    for tool in tools:
        if not platform_available(tool):
            continue
        entry = state["tools"].get(tool.name, {})
        if not entry.get("enabled", tool.enabled):
            continue
        n += 1
        status, _, _ = probe(tool, entry)
        try:
            if status == "installed":
                update(tool, state, log=log)
            else:
                install(tool, state, log=log)
        except AppError as e:
            errors += 1
            log(f"apptools: {e}")
    if n == 0:
        log("apptools: nothing to sync (enable tools first)")
    elif errors:
        log(f"apptools: sync finished with {errors} error(s)")
    return errors


def clean_unmanaged(state: dict, tools: List[Tool], log: Callable[[str], None] = print, yes: bool = False) -> List[str]:
    """Return names that would be cleaned; if yes, uninstall them."""
    targets: List[str] = []
    for t in tools:
        entry = state["tools"].get(t.name, {})
        if entry.get("enabled", t.enabled):
            continue
        if probe(t, entry)[0] == "installed" and entry.get("recipe_kind"):
            targets.append(t.name)
    targets += [o for o in orphans_safe(state, tools) if o not in targets]
    return targets


def orphans_safe(state: dict, tools: List[Tool]) -> List[str]:
    return registry.orphans(state, tools)



def _probe_recipe(tool: Tool, recipe: object, entry: dict) -> str:
    """Return "installed" (apptools-managed), "external" (on PATH only), or "missing"."""
    plat = platform()
    if entry.get("shims") and any(util.expand(s).exists() for s in entry["shims"]):
        return "installed"
    if entry.get("placed") and any(util.expand(p).exists() for p in entry["placed"]):
        return "installed"
    if isinstance(recipe, Shell):
        return "installed" if (recipe.check and util.which(recipe.check[0])) else "missing"
    if isinstance(recipe, Git):
        d = util.expand(recipe.into or f"~/.local/{tool.name}")
        if (d / ".git").exists():
            return "installed"
        return "external" if util.which(tool.name) else "missing"
    if getattr(recipe, "bin", None):
        if shims.shim_exists_for(recipe.bin):
            return "installed"
        return "external" if util.which(Path(recipe.bin).name) else "missing"
    if isinstance(recipe, File):
        dest = _extract_into(tool, recipe, plat)
        name = recipe.name or util.basename_from_url(recipe.url)
        if (dest / name).exists():
            return "installed"
        return "external" if _which_any(name) else "missing"
    if isinstance(recipe, Archive) and recipe.pick:
        dest = _extract_into(tool, recipe, plat)
        pat = Path(recipe.pick).name
        if dest.is_dir() and any(fnmatch.fnmatch(p.name, pat) for p in dest.iterdir() if p.is_file()):
            return "installed"
        return "external" if _which_any(pat) else "missing"
    d = _extract_into(tool, recipe, plat)
    if d.is_dir() and any(d.iterdir()):
        return "installed"
    return "external" if util.which(tool.name) else "missing"


def _which_any(name: str) -> bool:
    candidates = [name]
    if name.lower().endswith(".exe"):
        candidates.append(name[:-4])
    return any(util.which(c) for c in candidates)


def _recipe_version(tool: Tool, recipe: object) -> Optional[str]:
    if isinstance(recipe, Shell):
        if recipe.check:
            return util.version_of(recipe.check)
        return None
    if getattr(recipe, "bin", None):
        binp = shims.resolve_bin(recipe.bin)
        if not binp.exists():
            alt = util.which(Path(recipe.bin).name)
            if alt:
                return util.version_of([alt])
        return util.version_of([str(binp)])
    if isinstance(recipe, File):
        dest = _extract_into(tool, recipe, platform())
        name = recipe.name or util.basename_from_url(recipe.url)
        return util.version_of([str(dest / name)])
    return None


def probe(tool: Tool, entry: dict) -> Tuple[str, Optional[str], Optional[str]]:
    """Return (status, method, version); status is installed/external/missing."""
    plat = platform()
    avail = available_methods(tool, plat)
    wanted = entry.get("method")
    if wanted:
        for name, method in avail:
            if name == wanted:
                recipe = method.sources[plat]
                status = _probe_recipe(tool, recipe, entry)
                if status != "missing":
                    return status, name, entry.get("version") or _recipe_version(tool, recipe)
                break
    for name, method in avail:
        recipe = method.sources[plat]
        status = _probe_recipe(tool, recipe, entry)
        if status != "missing":
            return status, name, _recipe_version(tool, recipe)
    try:
        chosen, _, _ = resolve(tool, entry.get("method"))
    except AppError:
        chosen = entry.get("method")
    return "missing", chosen, None
