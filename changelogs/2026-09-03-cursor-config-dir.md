# Pin Cursor CLI config dir to ~/.cursor

Date: 2026-09-03

## What changed

Cursor CLI honors `XDG_CONFIG_HOME` and then stores `cli-config.json` /
`auth.json` under `~/.config/cursor`. The GUI never loads shell env, so it
keeps using `~/.cursor`. Those two copies diverge, and a symlink between them
breaks on the CLI's atomic rename.

Chezmoi-managed Cursor files stay under `~/.config/cursor/` with symlinks at
`~/.cursor/` (mcp.json, statusline.py). Runtime state (`cli-config.json`,
`auth.json`) must live as regular files in `~/.cursor`.

`~/.zshenv` is a `create_` file, so the new `CURSOR_CONFIG_DIR` export does
not land on machines that already have one.

## Impact

- Shells that export `XDG_CONFIG_HOME` but not `CURSOR_CONFIG_DIR` keep
  writing CLI state to `~/.config/cursor`, which the GUI cannot see.
- GUI login looks for `~/.cursor/auth.json`.

## Migration steps

```zsh
# Pin CLI to the GUI default. ~/.zshenv is create_ — edit in place.
grep -q '^export CURSOR_CONFIG_DIR=' ~/.zshenv || cat >> ~/.zshenv <<'EOF'

# Cursor GUI does not load shell env and defaults to ~/.cursor. Pin the CLI to
# the same directory so XDG_CONFIG_HOME does not split cli-config / auth.
export CURSOR_CONFIG_DIR="${CURSOR_CONFIG_DIR:-$HOME/.cursor}"
EOF

# Move runtime files onto the no-env path. Skip if already there.
if [[ -L ~/.cursor/cli-config.json ]]; then
  rm ~/.cursor/cli-config.json
fi
if [[ -f ~/.config/cursor/cli-config.json && ! -f ~/.cursor/cli-config.json ]]; then
  mv ~/.config/cursor/cli-config.json ~/.cursor/cli-config.json
fi
if [[ -f ~/.config/cursor/auth.json && ! -f ~/.cursor/auth.json ]]; then
  mv ~/.config/cursor/auth.json ~/.cursor/auth.json
fi
```

## Completion condition

`~/.zshenv` exports `CURSOR_CONFIG_DIR`, `~/.cursor/cli-config.json` is a
regular file (not a symlink), and `~/.cursor/auth.json` exists.
