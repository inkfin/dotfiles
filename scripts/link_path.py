import os
import platform
import subprocess
from typing import Callable

"""
src (str): The source file or directory.
dest (str): The destination for the symbolic link. (NewFile)
"""

# Windows

soft_link_map_win: dict[str, str] = {
    os.path.expanduser("~/.config/nvim"): os.path.join(
        os.environ["LOCALAPPDATA"], "nvim"
    ),
    os.path.expanduser("~/.config/lf"): os.path.join(
        os.environ["LOCALAPPDATA"], "lf"
    ),
    "C:/dev": os.path.expanduser("~/dev"),
    "C:/dev/Code": os.path.expanduser("~/Code"),
}


def make_symlink_windows(src: str, dest: str):
    powershell_or_cmd_command = '(dir 2>&1 *`|echo CMD);&<# rem #>echo PowerShell'
    if not os.path.exists(dest):
        try:
            shell_type = subprocess.check_output(powershell_or_cmd_command, shell=True).decode().strip()
            if "powershell" in shell_type.lower():
                # PowerShell
                subprocess.check_call(
                    f'New-Item -Type Junction -Target "{src}" -Path "{dest}"', shell=True
                )
            else:
                # cmd
                subprocess.check_call(f'mklink /J "{dest}" "{src}"', shell=True)
            print(f"Linking {src} to {dest}")
        except subprocess.CalledProcessError as e:
            print(f"Failed to create junction: {e.output}")
    else:
        print(f"Skipping {src} to {dest}")


# MacOS

soft_link_map_mac: dict[str, str] = {}

# Linux

soft_link_map_linux: dict[str, str] = {}


def make_symlink_posix(src: str, dest: str):
    if not os.path.exists(dest):
        os.symlink(src, dest)
        print(f"Linking {src} to {dest}")
    else:
        print(f"Skipping {src} to {dest}")


soft_link_map: dict[str, str]
make_symlink: Callable[[str, str], None]

if platform.system() == "Windows":
    soft_link_map = soft_link_map_win
    make_symlink = make_symlink_windows
elif platform.system() == "Darwin":
    soft_link_map = soft_link_map_mac
    make_symlink = make_symlink_posix
elif platform.system() == "Linux":
    soft_link_map = soft_link_map_linux
    make_symlink = make_symlink_posix

for src, dest in soft_link_map.items():
    # normalize paths
    src = os.path.normpath(src)
    dest = os.path.normpath(dest)
    make_symlink(src, dest)
