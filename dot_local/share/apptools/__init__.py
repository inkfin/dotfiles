"""apptools: per-machine third-party tool manager.

A tool catalog is declared in ~/.config/apptools/config.py as a TOOLS list.
Each tool maps platforms to install recipes (Archive/File/Git/Shell); tools
with more than one way to install expose several "methods" (e.g. local vs brew).
Per-machine selection is tracked in ~/.local/state/apptools/state.json.
"""

from __future__ import annotations

import os
import sys
from dataclasses import dataclass, field
from typing import Dict, List, Optional

__version__ = "0.1.0"

PLATFORMS = ("windows", "darwin", "linux")


class AppError(Exception):
    """Fatal, user-facing failure."""


def ensure_share_on_path() -> None:
    here = os.path.dirname(os.path.abspath(__file__))
    share = os.path.dirname(here)
    if share not in sys.path:
        sys.path.insert(0, share)


@dataclass
class Recipe:
    pass


@dataclass
class Archive(Recipe):
    url: str
    strip: int = 0
    pick: Optional[str] = None
    include: Optional[List[str]] = None
    exclude: Optional[List[str]] = None
    bin: Optional[str] = None
    shim_env: Optional[Dict[str, str]] = None
    into: Optional[str] = None
    executable: bool = True


@dataclass
class File(Recipe):
    url: str
    name: Optional[str] = None
    executable: bool = True
    into: Optional[str] = None
    bin: Optional[str] = None
    shim_env: Optional[Dict[str, str]] = None


@dataclass
class Git(Recipe):
    url: str
    depth: int = 1
    branch: Optional[str] = None
    into: Optional[str] = None


@dataclass
class Shell(Recipe):
    install: str
    uninstall: Optional[str] = None
    update: Optional[str] = None
    check: Optional[List[str]] = None


@dataclass
class Method:
    sources: Dict[str, Recipe] = field(default_factory=dict)
    check: Optional[List[str]] = None


@dataclass
class Tool:
    name: str
    desc: str = ""
    group: str = ""
    default_method: Optional[str] = None
    enabled: bool = True
    methods: Optional[Dict[str, Method]] = None
    sources: Optional[Dict[str, Recipe]] = None
    bin: Optional[str] = None
    shim_env: Optional[Dict[str, str]] = None

    def __post_init__(self) -> None:
        if self.methods is None:
            self.methods = {"local": Method(sources=self.sources or {})}
            local = self.methods["local"]
            for recipe in local.sources.values():
                if isinstance(recipe, (Archive, File)):
                    if recipe.bin is None and self.bin:
                        recipe.bin = self.bin
                    if recipe.shim_env is None and self.shim_env:
                        recipe.shim_env = self.shim_env


__all__ = [
    "AppError",
    "Archive",
    "File",
    "Git",
    "Method",
    "PLATFORMS",
    "Recipe",
    "Shell",
    "Tool",
    "__version__",
    "ensure_share_on_path",
]
