# AGENTS.md — Chezmoi Dotfiles Conventions

> Rules for AI agents (OpenCode / Claude Code / etc.) when modifying this repo.

## Core Philosophy

- **Single source of truth**: all configs live under `dot_config/` regardless of platform.
- **Concise & idempotent**: every template must be minimal; running `chezmoi apply` twice must be a no-op.
- **Fast**: avoid unnecessary externals or heavy templates. Prefer simple Go template logic.

## Directory Layout

```
dot_config/          # Canonical config root (~/.config)
  nvim.mini/         #   → daily Neovim config (minimal, fast startup)
  nvim.lazyvim/      #   → LazyVim reference (heavier, feature-rich)
  symlink_nvim.tmpl  #   → symlink ~/.config/nvim → selected config
  alacritty/
  lazygit/           #   → OS-aware template, uses symlink on Windows
  opencode/          #   → create_ prefix: generated once, never overwritten
  ...
AppData/             # Windows-specific (%APPDATA%)
  Roaming/
    symlink_<app>.tmpl  # → symlink back to dot_config/<app>/
dot_local/           # ~/.local
  scripts/           #   → executable_ prefix for scripts
```

## Cross-platform Strategy

1. **Canonical config** lives in `dot_config/<app>/`. Templates use `{{ if eq .chezmoi.os "windows" }}` for OS branches.

2. **Windows `%APPDATA%` apps**: do NOT put configs directly in `AppData/Roaming/`. Instead:
   - Config goes in `dot_config/<app>/`
   - Create `AppData/Roaming/symlink_<app>.tmpl` pointing to `{{ .chezmoi.homeDir }}/.config/<app>`
   - This mirrors what Unix apps already do (reading `~/.config/<app>/`).

   Example — lazygit:
   ```
   dot_config/lazygit/config.yml.tmpl           # real config
   AppData/Roaming/symlink_lazygit.tmpl          # symlink on Windows only
   ```

3. **OS filtering**: `.chezmoiignore` uses `{{ if eq/ne .chezmoi.os "xxx" }}` blocks to exclude per-platform files.

## File Naming Conventions

| Prefix/Suffix | Purpose |
|---|---|
| `dot_config/` | Maps to `~/.config/` — use for all app configs |
| `dot_local/` | Maps to `~/.local/` — use for scripts, state, executables |
| `executable_` | Marks file as executable (`chmod +x` on Unix) |
| `create_` | Only create once, never overwrite existing (e.g. opencode config) |
| `symlink_` | Target becomes a symlink; source content = link destination |
| `private_` | Sensitive / OS-specific dirs (e.g. `private_karabiner/`) |
| `.tmpl` | Go template, rendered before writing |
| `.xxx` in ignore | Stop tracking a file/dir without deleting source (soft removal) |

## `.tmpl` Template Rules

- Use `{{-` to trim whitespace: `{{- if ... }}`
- OS checks: `{{ if eq .chezmoi.os "windows" }}` / `"darwin"` / `"linux"`
- Profile checks: `{{ if eq .profile "work" }}`
- Home dir: `{{ .chezmoi.homeDir }}`
- External data: `{{ .external.xxx }}` (from `.chezmoidata.toml` or platform keys)
- Keep templates short. If logic exceeds 5 conditionals, reconsider the design.

## `.chezmoiignore` Rules

- Use OS blocks for platform-specific exclusions:
  ```
  {{ if ne .chezmoi.os "windows" }}
  AppData/          # Windows-only path
  {{ end }}
  ```
- To stop managing a file but keep it on disk: add its path to `.chezmoiignore`. The file remains on the system but chezmoi stops tracking it (e.g. `.config/nvim.old`).
- Guard the inverse: on Windows, exclude Unix scripts (`install-packages.sh`, `.tmux/`, `.zshrc`) with `{{ if eq .chezmoi.os "windows" }}`.

## Neovim Setup

- `nvim.mini/` is the **daily driver** — keep it minimal, fast, and well-tested.
- `nvim.lazyvim/` is the reference full-featured config.
- `symlink_nvim.tmpl` selects which config is active via `{{ .external.neovim_dir }}`.
- Shared data (spell, undo, etc.) goes in `nvim_data/` (not in either config dir).

Do NOT add plugins or heavy config to nvim.mini unless essential for daily work. Prefer built-in Neovim features over plugins.

## Adding a New App

1. Create `dot_config/<app>/` with the config file(s).
2. If the app reads a different path on Windows (`%APPDATA%/<app>`), add `AppData/Roaming/symlink_<app>.tmpl`.
3. If any path or command differs per OS, use a `.tmpl` template.
4. Update `.chezmoiignore` if the app is platform-specific.
5. Keep configs minimal — no commented-out defaults, no boilerplate.

## Scripts

- All custom scripts go in `dot_local/scripts/` with `executable_` prefix.
- Windows wrappers use `.bat` extension and call the Python/Unix script via `python "%~dp0<script>" %*`.
- Prefer Python for cross-platform scripts; avoid bash on Windows.

## Testing

After changes:
1. `chezmoi diff` — review what will change
2. `chezmoi apply --dry-run --verbose` — verify targets
3. `chezmoi apply` — deploy
4. Verify the app actually works (e.g. open lazygit and press `C`)
