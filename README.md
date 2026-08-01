# README

```
>
>   ____ _   _ _____ _______  __  ___ ___ 
>  / ___| | | | ____|__  /  \/  |/ _ \_ _|
> | |   | |_| |  _|   / /| |\/| | | | | | 
> | |___|  _  | |___ / /_| |  | | |_| | | 
>  \____|_| |_|_____/____|_|  |_|\___/___|
>
```

> This is *inkfin*'s messy dotfiles repository

Visit the [user guide in chezmoi.io](https://www.chezmoi.io/user-guide/command-overview/) for documents.

### Machine Specific Settings

> [documents](https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/)

Config current profiles in `$HOME/.config/chezmoi/chezmoi.toml`.

```toml
# personal
[data]
    email = "inkfinite@qq.com"
    name = "inkfin"
    profile = "personal"
[git]
    autoCommit = false
    autoPush = false
[diff]
    command = "nvim"
    args = ["-d", "{{ .Destination }}", "{{ .Target }}"]
[merge]
    command = "nvim"
    args = ["-d", "{{ .Destination }}", "{{ .Source }}"]

# Windows
[cd]
    command = "pwsh.EXE"
    args = ["-NoLogo"]

# work
[data]
    email = ""
    name = "Ziyue Zhang"
    profile = "work"
```

### Directory Structure

```
dot_config/          # All configs live here (~/.config)
  nvim.mini/         #   daily Neovim config (minimal, fast)
  nvim.lazyvim/      #   LazyVim reference
  symlink_nvim.tmpl  #   switches active nvim config
  lazygit/           #   OS-aware template with AI commit keybind
  opencode/          #   create_ prefix: only generated once
  ...
AppData/             # Windows %APPDATA% symlinks → dot_config/
dot_local/scripts/   # Cross-platform scripts
```

### Cross-platform Strategy

1. **All configs in `dot_config/`** — single source of truth regardless of OS.
2. **Windows apps reading `%APPDATA%`**: use `AppData/Roaming/symlink_<app>.tmpl`
   to create a symlink pointing back to `dot_config/<app>/`.
3. **OS differences** handled via `{{ if eq .chezmoi.os "windows" }}` in `.tmpl` templates.
4. **Stopping tracking** without deleting on disk: add `.xxx` path to `.chezmoiignore`
   (e.g. `.config/nvim.old`).
5. **Scripts**: cross-platform logic in Python, `.bat` wrapper for Windows.
6. For detailed conventions, see [AGENTS.md](./AGENTS.md).

### Pre-installation steps

#### Windows

Install Scoop in Windows

```shell

Write-host "Installing scoop ..." -f Green
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

```
