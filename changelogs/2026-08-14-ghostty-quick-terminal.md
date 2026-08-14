# Migrate iTerm2 hotkey window to Ghostty quick terminal

Date: 2026-08-14
Status: applied

## What changed

Added `dot_config/ghostty/` (template-driven) and three preset scripts
(`ghostty-nu-tab`, `ghostty-nu-window`, `ghostty-ssh-tab`). The user's
quake/hotkey terminal habit (`ctrl+alt+z`) moved from iTerm2 to Ghostty's
`toggle_quick_terminal` global keybind. iTerm2 config is left untouched; this
is informational for machines that still have iTerm2 as the default terminal.

## Impact

- Machines that previously relied on iTerm2 hotkey window (`ctrl+alt+z`) need
  Ghostty installed and Accessibility permission granted for the global hotkey.
- New shell sessions now default to zsh (Ghostty `command` not overridden).
- Ghostty reads fonts from chezmoi `data.font` (centralized font names).

## Migration steps

```zsh
brew install --cask ghostty nushell
# Grant Accessibility to Ghostty: System Settings > Privacy & Security
chezmoi apply
ghostty-nu-tab    # smoke test a nushell tab preset
```

## Completion condition

- `ghostty +show-config` shows `font-family = FantasqueSansM Nerd Font Mono`
  and `keybind = global:ctrl+alt+z=toggle_quick_terminal`.
- `ctrl+alt+z` toggles a fullscreen quick terminal.
