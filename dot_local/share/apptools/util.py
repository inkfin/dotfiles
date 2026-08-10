"""Low-level helpers: platform detection, downloads, extraction, subprocesses."""

from __future__ import annotations

import fnmatch
import os
import shlex
import shutil
import stat
import subprocess
import sys
import tarfile
import time
import zipfile
from pathlib import Path
from urllib.parse import urlparse
from urllib.request import Request, urlopen
from typing import Callable, List, Optional

from . import AppError

USER_AGENT = "apptools/0.2"
_CHUNK = 1 << 16
_PROGRESS_EVERY = 1 << 20  # log progress at most every 1 MiB


def os_name() -> str:
    p = sys.platform.lower()
    if p.startswith("win"):
        return "windows"
    if p == "darwin":
        return "darwin"
    return "linux"


def expand(path: str) -> Path:
    return Path(os.path.expandvars(os.path.expanduser(path)))


def home() -> Path:
    return Path.home()


def download(url: str, dest: Path, progress: Optional[Callable[[int, int], None]] = None, timeout: int = 60, overall: float = 300.0) -> Path:
    dest = Path(dest)
    dest.parent.mkdir(parents=True, exist_ok=True)
    req = Request(url, headers={"User-Agent": USER_AGENT})
    tmp = dest.with_name(dest.name + ".part")
    deadline = time.monotonic() + overall
    try:
        with urlopen(req, timeout=timeout) as resp:
            total = int(resp.headers.get("Content-Length") or 0)
            done = 0
            last = 0
            with open(tmp, "wb") as fh:
                while True:
                    if time.monotonic() > deadline:
                        raise AppError(f"download timed out after {overall}s: {url}")
                    chunk = resp.read(_CHUNK)
                    if not chunk:
                        break
                    fh.write(chunk)
                    done += len(chunk)
                    if progress and (done - last >= _PROGRESS_EVERY or done == total):
                        last = done
                        progress(done, total)
            if progress:
                progress(done, total)
    except Exception as e:
        tmp.unlink(missing_ok=True)
        raise AppError(f"download failed: {url}: {e}") from e
    replace_retry(tmp, dest)
    return dest


def _strip_path(name: str, strip: int) -> Optional[str]:
    name = name.replace("\\", "/").strip()
    if not name:
        return None
    parts = [p for p in name.split("/") if p]
    if parts and parts[0] == ".":
        parts = parts[1:]
    if not parts:
        return None
    if strip:
        if len(parts) <= strip:
            return None
        parts = parts[strip:]
    return "/".join(parts)


def _safe_target(dest: Path, rel: str) -> Path:
    target = (dest / rel).resolve()
    if not str(target).startswith(str(dest.resolve())):
        raise AppError(f"unsafe archive path: {rel}")
    return target


def _match(rel: str, include: Optional[List[str]], exclude: Optional[List[str]]) -> bool:
    if exclude and any(fnmatch.fnmatch(rel, pat) for pat in exclude):
        return False
    if include and not any(fnmatch.fnmatch(rel, pat) or fnmatch.fnmatch(rel, pat.rstrip("/") + "/**") for pat in include):
        return False
    return True


def extract(archive: Path, dest: Path, strip: int = 0, include: Optional[List[str]] = None, exclude: Optional[List[str]] = None) -> List[str]:
    dest = Path(dest)
    dest.mkdir(parents=True, exist_ok=True)
    created: List[str] = []
    name = str(archive).lower()
    if name.endswith(".zip"):
        with zipfile.ZipFile(archive) as zf:
            for info in zf.infolist():
                rel = _strip_path(info.filename, strip)
                if rel is None or not _match(rel, include, exclude):
                    continue
                target = _safe_target(dest, rel)
                if info.is_dir():
                    target.mkdir(parents=True, exist_ok=True)
                    continue
                target.parent.mkdir(parents=True, exist_ok=True)
                with zf.open(info) as src, open(target, "wb") as out:
                    shutil.copyfileobj(src, out)
                mode = (info.external_attr >> 16) & 0o777
                if mode:
                    target.chmod(mode)
                created.append(str(target))
    else:
        with tarfile.open(archive) as tf:
            for member in tf.getmembers():
                rel = _strip_path(member.name, strip)
                if rel is None or not _match(rel, include, exclude):
                    continue
                target = _safe_target(dest, rel)
                if member.isdir():
                    target.mkdir(parents=True, exist_ok=True)
                    continue
                if member.islnk() or member.issym():
                    target.parent.mkdir(parents=True, exist_ok=True)
                    link = member.linkname
                    if target.exists() or target.is_symlink():
                        target.unlink(missing_ok=True)
                    os.symlink(link, target)
                    created.append(str(target))
                    continue
                if member.isfile():
                    target.parent.mkdir(parents=True, exist_ok=True)
                    with open(target, "wb") as out:
                        src = tf.extractfile(member)
                        if src is None:
                            continue
                        shutil.copyfileobj(src, out)
                    target.chmod(member.mode & 0o777)
                    created.append(str(target))
    return created


def find_files(root: Path, pattern: str) -> List[Path]:
    root = Path(root)
    out: List[Path] = []
    if not root.exists():
        return out
    for p in sorted(root.rglob("*")):
        if not p.is_file():
            continue
        rel = p.relative_to(root).as_posix()
        if fnmatch.fnmatch(rel, pattern) or fnmatch.fnmatch(p.name, pattern):
            out.append(p)
    return out


def run(
    cmd: List[str],
    cwd: Optional[Path] = None,
    log: Callable[[str], None] = print,
    check: bool = False,
    timeout: Optional[float] = 1800.0,
) -> subprocess.CompletedProcess:
    """Run a command capturing output.

    stdin is detached so interactive children (brew/sudo/installer prompts)
    cannot block on the TUI's terminal. `timeout` guards against hangs.
    """
    log(f"$ {' '.join(cmd)}")
    try:
        proc = subprocess.run(
            cmd,
            cwd=cwd,
            text=True,
            capture_output=True,
            stdin=subprocess.DEVNULL,
            timeout=timeout,
        )
    except FileNotFoundError as e:
        raise AppError(f"command not found: {cmd[0]}") from e
    except subprocess.TimeoutExpired as e:
        raise AppError(f"command timed out after {timeout}s: {' '.join(cmd)}") from e
    if proc.stdout and proc.stdout.strip():
        for line in proc.stdout.rstrip().splitlines():
            log(line)
    if proc.stderr and proc.stderr.strip():
        for line in proc.stderr.rstrip().splitlines():
            log(line)
    if check and proc.returncode != 0:
        raise AppError(f"command failed ({proc.returncode}): {' '.join(cmd)}")
    return proc


def shell_command(text: str) -> List[str]:
    return shlex.split(text)


def version_of(cmd: List[str], timeout: int = 15) -> Optional[str]:
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
        if proc.returncode != 0:
            return None
        out = (proc.stdout or proc.stderr).strip()
        for line in out.splitlines():
            line = line.strip()
            if line:
                return line[:100]
    except Exception:
        pass
    return None


def which(cmd: str) -> Optional[str]:
    return shutil.which(cmd)


def rmtree_retry(path: Path, attempts: int = 4, delay: float = 0.3) -> None:
    path = Path(path)
    if path.exists():
        for root, dirs, files in os.walk(path):
            for name in files:
                try:
                    os.chmod(os.path.join(root, name), stat.S_IWRITE)
                except OSError:
                    pass
    last: Optional[BaseException] = None
    for i in range(attempts):
        try:
            shutil.rmtree(path)
            return
        except (PermissionError, OSError) as e:
            last = e
            time.sleep(delay * (i + 1))
    raise AppError(f"cannot remove {path}: {last}")


def replace_retry(src: Path, dest: Path, attempts: int = 6, delay: float = 0.3) -> None:
    """os.replace with retries — Windows locks (AV scans, running exes) are transient."""
    last: Optional[BaseException] = None
    for i in range(attempts):
        try:
            os.replace(src, dest)
            return
        except (PermissionError, OSError) as e:
            last = e
            time.sleep(delay * (i + 1))
    raise AppError(f"cannot replace {dest}: {last}")


def write_text_retry(path: Path, text: str, attempts: int = 6, delay: float = 0.3) -> None:
    """Atomic write of text via a temp file + replace, retrying on locks."""
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(path.name + ".tmp")
    last: Optional[BaseException] = None
    for i in range(attempts):
        try:
            tmp.write_text(text, encoding="utf-8")
            os.replace(tmp, path)
            return
        except (PermissionError, OSError) as e:
            last = e
            time.sleep(delay * (i + 1))
    tmp.unlink(missing_ok=True)
    raise AppError(f"cannot write {path}: {last}")


def basename_from_url(url: str) -> str:
    return Path(urlparse(url).path).name or "download"
