# Migrate platform-specific zshrc to unified chezmoi-managed zsh layout

Date: 2026-08-05

## What changed

Replaced the old platform-specific entry points (`zshrc_darwin`,
`zshrc_linux`, `zshrc_ubuntu`, `zshrc_fedora`, `zshrc_opensuse`,
`zshrc_arch`, `zshrc_tencentos`, `zshrc_clean`) and the Oh My Zsh setup with
a single chezmoi-managed layout. The current layout has four startup layers:
`~/.zshenv`, `~/.zprofile`, `~/.zshrc`, `~/.zshrc.d/local.zsh`.

This was the first destructive migration; previously recorded via the
`zshrc-migration` skill (now retired).

## Impact

- Machines still on the old layout have `~/.zshenv`/`~/.zprofile` as
  `create_` files: chezmoi creates them once and never overwrites later local
  edits, so old versions must be merged manually or moved to the backup.
- Docker Desktop, Conda, and host-specific blocks now live in
  `~/.zshrc.d/local.zsh` (machine-local, not tracked).
- OMZ is still used but installed from `~/.zshrc.d/omz.zsh` when missing.
- `~/.oh-my-zsh` must NOT be deleted until the new config is verified.

## Migration steps

```zsh
# backup
backup="$HOME/.zsh-migration-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup" && cp -p ~/.zshenv ~/.zprofile ~/.zshrc "$backup" 2>/dev/null

# apply tracked source
chezmoi diff
chezmoi apply --dry-run --verbose
chezmoi apply

# verify each startup mode
zsh -n ~/.zshenv && zsh -n ~/.zprofile && zsh -n ~/.zshrc
zsh -lic 'print -r -- "HISTFILE=$HISTFILE"; whence -w omz-update'

# only after verification, remove obsolete entry points
grep -RsnE 'zshrc_(darwin|linux|ubuntu|fedora|opensuse|arch|tencentos|clean)' \
  ~/.zshrc ~/.zshrc.d ~/.config/fish 2>/dev/null || true
```

## Completion condition

- `~/.zshrc` sources the unified `~/.zshrc.d/zshrc`; no `zshrc_darwin` /
  `zshrc_linux` / `zshrc_*` entry points remain referenced.
- `HISTFILE` stays `~/.zshrc.d/.histfile`.
- Conda and Docker blocks load from `~/.zshrc.d/local.zsh`.
- `omz-update` is a function in a login interactive shell.
