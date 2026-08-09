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
        shim = bdir / f"{name}.bat"
        shim.write_text(f"@echo off\r\n@\"{binary}\" %*\r\n", encoding="utf-8")
        return shim
    if not binary.exists():
        raise FileNotFoundError(f"binary not found: {binary}")
    if not os.access(binary, os.X_OK):
        binary.chmod(binary.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
    shim = bdir / name
    if env:
        lines = ["#!/bin/sh"]
        for k, v in env.items():
            lines.append(f'export {k}="{v}"')
        lines.append(f'exec "{binary}" "$@"')
        shim.write_text("\n".join(lines) + "\n", encoding="utf-8")
        shim.chmod(shim.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
    else:
        if shim.exists() or shim.is_symlink():
            shim.unlink()
        os.symlink(str(binary), shim)
    return shim


def remove_shims(names: List[str]) -> None:
    for n in names:
        try:
            p = util.expand(n)
            if p.is_symlink() or p.is_file():
                p.unlink()
        except FileNotFoundError:
            pass


def shim_exists_for(target: str) -> bool:
    binary = resolve_bin(target)
    if not binary.exists():
        return False
    if util.os_name() == "windows":
        return (bin_dir() / f"{shim_name(binary)}.bat").exists()
    return (bin_dir() / shim_name(binary)).exists() or binary.exists()
