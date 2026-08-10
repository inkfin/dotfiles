"""Create/remove ~/.local/bin shims so installed tools stay on PATH."""

from __future__ import annotations

import os
import stat
from pathlib import Path
from typing import Dict, List, Optional

from . import util


def bin_dir() -> Path:
    return util.expand("~/.local/bin")


def resolve_bin(candidate: str) -> Path:
    p = util.expand(candidate)
    if p.exists():
        return p
    if util.os_name() == "windows" and not p.suffix.lower() == ".exe":
        exe = p.with_suffix(".exe")
        if exe.exists():
            return exe
    return p


def shim_name(binary: Path) -> str:
    name = binary.name
    if util.os_name() == "windows" and name.lower().endswith(".exe"):
        name = name[: -len(".exe")]
    return name


def create_shim(target: str, env: Optional[Dict[str, str]] = None) -> Path:
    binary = resolve_bin(target)
    name = shim_name(binary)
    bdir = bin_dir()
    bdir.mkdir(parents=True, exist_ok=True)
    plat = util.os_name()
    if plat == "windows":
        shim = bdir / f"{name}.cmd"
        # .cmd preferred over .bat (slightly cleaner arg handling); fall back path kept
        old_bat = bdir / f"{name}.bat"
        body = (
            "@echo off\r\n"
            "setlocal\r\n"
        )
        if env:
            for k, v in env.items():
                body += f"set \"{k}={v}\"\r\n"
        body += f"\"{binary}\" %*\r\n"
        shim.write_text(body, encoding="utf-8")
        if old_bat.exists() and old_bat != shim:
            try:
                old_bat.unlink()
            except OSError:
                pass
        return shim
    if not binary.exists():
        raise FileNotFoundError(f"binary not found: {binary}")
    if not os.access(binary, os.X_OK):
        binary.chmod(binary.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
    shim = bdir / name
    # refuse to clobber a real non-shim file that isn't ours
    if shim.exists() and not shim.is_symlink():
        try:
            text = shim.read_text(encoding="utf-8", errors="replace")
        except OSError:
            text = ""
        if "exec " not in text and not text.startswith("#!/"):
            raise FileNotFoundError(f"refusing to overwrite non-shim file: {shim}")
    if env:
        lines = ["#!/bin/sh", "# apptools-shim"]
        for k, v in env.items():
            lines.append(f'export {k}="{v}"')
        lines.append(f'exec "{binary}" "$@"')
        if shim.exists() or shim.is_symlink():
            shim.unlink()
        shim.write_text("\n".join(lines) + "\n", encoding="utf-8")
        shim.chmod(shim.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
    else:
        if shim.exists() or shim.is_symlink():
            shim.unlink()
        os.symlink(str(binary), shim)
    return shim


def remove_shims(names: List[str]) -> None:
    for n in names or []:
        try:
            p = util.expand(n)
            if p.is_symlink() or p.is_file():
                p.unlink()
            # also clear legacy .bat if we now use .cmd
            if p.suffix.lower() == ".cmd":
                bat = p.with_suffix(".bat")
                if bat.is_file():
                    bat.unlink()
        except FileNotFoundError:
            pass
        except OSError:
            pass


def shim_exists_for(target: str) -> bool:
    binary = resolve_bin(target)
    if not binary.exists():
        return False
    if util.os_name() == "windows":
        bdir = bin_dir()
        base = shim_name(binary)
        return (bdir / f"{base}.cmd").exists() or (bdir / f"{base}.bat").exists()
    return (bin_dir() / shim_name(binary)).exists() or binary.exists()
