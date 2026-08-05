---
name: zshrc-migration
description: Migrate a machine from the old platform-specific zshrc and Oh My Zsh setup to the current chezmoi-managed zsh layout. Use when a machine still has zshrc_darwin, zshrc_linux, OMZ externals, create_env.zsh, or a hand-written ~/.zprofile.
---

# Zshrc Migration

Use this skill when moving an existing machine from the old zsh layout to the
current chezmoi-managed layout. The goal is to change the startup boundaries
without losing local integrations such as Docker Desktop or Conda.

## Target Layout

The current layout has four startup layers:

| File | Loaded by | Purpose |
| --- | --- | --- |
| `~/.zshenv` | every zsh process | exported environment, PATH, history path, machine defaults |
| `~/.zprofile` | login shells | Homebrew and other login-only environment setup |
| `~/.zshrc` | interactive shells | options, completion, OMZ, tools, aliases, local integrations |
| `~/.zshrc.d/local.zsh` | interactive shells | machine-local changes from Docker, Conda, or the user |

The chezmoi source files are:

```text
create_dot_zshenv
create_dot_zprofile
dot_zshrc.d/omz.zsh.tmpl
dot_zshrc.d/plugins.zsh.tmpl
dot_zshrc.d/custom.zsh.tmpl
dot_zshrc.d/dev.zsh.tmpl
dot_zshrc.d/homebrew.zsh.tmpl
dot_zshrc.d/create_local.zsh
```

`create_` means chezmoi creates the target once and does not overwrite later
local edits. This is intentional for `~/.zshenv`, `~/.zprofile`, and
`~/.zshrc.d/local.zsh`.

## Safety Rules

- Read the current files before changing or deleting anything.
- Back up old startup files before migration.
- Never copy API keys, access tokens, passwords, or private keys into the
  chezmoi source tree.
- Keep Docker Desktop, Conda, and other generated blocks in
  `~/.zshrc.d/local.zsh`.
- Do not run the OMZ official installer; it may rewrite `~/.zshrc`.
- Do not use `exact_dot_zshrc.d` unless every file in that directory is meant
  to be managed and deleted when absent from the source.
- Do not delete `~/.oh-my-zsh` until the new OMZ configuration has been
  applied and tested. The current layout still uses OMZ, but installs it from
  `~/.zshrc.d/omz.zsh` when missing.

## Migration Workflow

Run these commands in a fresh terminal. Keep the old terminal open until the
new shell has been verified.

### 1. Inspect the machine

```zsh
chezmoi managed | grep -E 'zsh|profile|agents/skills'
ls -la ~/.zshenv ~/.zprofile ~/.zshrc ~/.zshrc.d 2>/dev/null
grep -nE 'TOKEN|API_KEY|PASSWORD|SECRET|PRIVATE_KEY' ~/.zshrc ~/.zprofile ~/.zshenv ~/.zshrc.d/* 2>/dev/null
```

Treat every matching secret as local-only data. Do not paste it into a
commit, issue, or migration report.

### 2. Create a dated backup

```zsh
backup="$HOME/.zsh-migration-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup"
cp -p ~/.zshenv ~/.zprofile ~/.zshrc "$backup" 2>/dev/null
cp -pR ~/.zshrc.d "$backup/zshrc.d" 2>/dev/null
print "Backup: $backup"
```

If a file does not exist, `cp` may report an error; that is harmless. Confirm
the backup directory exists before continuing.

### 3. Separate local data from tracked configuration

Keep these kinds of content in the local file:

- Conda's `conda initialize` block
- Docker Desktop completion setup
- host-specific aliases
- private environment variables and tokens
- paths that exist only on this machine

The destination is:

```text
~/.zshrc.d/local.zsh
```

If the old configuration has `create_env.zsh` or `env.zsh`, do not blindly
copy it into the repository. Move non-secret machine defaults to the
`create_dot_zshenv` source only when they are appropriate for every machine;
otherwise keep them in `~/.zshrc.d/local.zsh` or the local `~/.zshenv`.

### 4. Apply the current chezmoi source

From the chezmoi source repository:

```zsh
chezmoi diff
chezmoi apply --dry-run --verbose
chezmoi apply
```

Because `create_` files do not overwrite existing targets, an old
`~/.zshenv` or `~/.zprofile` may remain unchanged. In that case, manually
merge the reviewed content from `create_dot_zshenv` and
`create_dot_zprofile`, or move the old target into the backup and run:

```zsh
chezmoi apply
```

Do not use `--force` as a substitute for reviewing local content. Confirm
that the target contents are correct first.

### 5. Verify each startup mode

Check syntax without loading the interactive configuration:

```zsh
zsh -n ~/.zshenv
zsh -n ~/.zprofile
zsh -n ~/.zshrc
zsh -n ~/.config/fzf/fzf_config.zsh
```

Check a login interactive shell:

```zsh
zsh -lic '
  print -r -- "ZSHCONF_HOME=$ZSHCONF_HOME"
  print -r -- "HISTFILE=$HISTFILE"
  print -r -- "EDITOR=$EDITOR"
  print -r -- "PATH=$PATH"
  whence -w omz-update
  whence -w _fzf_file_no_hidden
'
```

Expected behavior:

- `HISTFILE` remains `~/.zshrc.d/.histfile` for existing machines.
- `omz-update` is a function.
- `_fzf_file_no_hidden` is available when `fd` and fzf are installed.
- Homebrew environment is initialized once in login shells.
- Conda and Docker local blocks are loaded from `local.zsh`.

Start a new terminal and test completion, OMZ plugins, fzf shortcuts, Conda,
Docker, Starship, zoxide, and the user's important aliases before deleting
anything.

## Remove Obsolete Files

Only remove files after the new shell passes the verification above. The old
platform-specific entry points are obsolete when `~/.zshrc` points to the
unified `~/.zshrc.d/zshrc`:

```text
~/.zshrc.d/zshrc_darwin
~/.zshrc.d/zshrc_linux
~/.zshrc.d/zshrc_ubuntu
~/.zshrc.d/zshrc_fedora
~/.zshrc.d/zshrc_opensuse
~/.zshrc.d/zshrc_arch
~/.zshrc.d/zshrc_tencentos
~/.zshrc.d/zshrc_clean
```

Remove them only if they are not referenced by another shell or script:

```zsh
grep -RsnE 'zshrc_(darwin|linux|ubuntu|fedora|opensuse|arch|tencentos|clean)' \
  ~/.zshrc ~/.zshrc.d ~/.config/fish 2>/dev/null
```

Do not delete these current or local files:

```text
~/.zshenv
~/.zprofile
~/.zshrc
~/.zshrc.d/local.zsh
~/.zshrc.d/.histfile
~/.oh-my-zsh
```

The old `.oh-my-zsh` directory is still used by the current configuration.
If OMZ is not wanted, that is a separate migration decision and requires
removing the OMZ plugin list and replacing its built-in plugin behavior.

## Final Checks

```zsh
chezmoi diff
chezmoi apply --dry-run --verbose
git -C "$(chezmoi source-path ~/.zshrc | xargs dirname)" diff --check
```

Report the backup path, files removed, local integrations retained, and the
commands used for verification. Never include secret values in the report.
