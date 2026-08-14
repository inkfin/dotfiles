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
- **Fonts come from `{{ .font.xxx }}`** — never hardcode a font name in an app
  config. Centralized per-machine in `.chezmoi.toml.tmpl` `[data.font]`
  (`term_font`, `editor_font`, `ui_font`, `cjk_font`), because nerd font names
  differ across platforms/installs. To change on one machine, edit
  `~/.config/chezmoi/chezmoi.toml` `[data.font]` — one place, every app updates.
- **`{{ }}` in a comment is still executed.** `.chezmoi.toml.tmpl` and every
  `.tmpl` file are Go templates; a commented-out `{{ .font.xxx }}` errors with
  `map has no entry for key "xxx"`. Write example placeholders as `font.xxx`
  without the braces, or escape them.

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

## Agent Skills — Two Homes

There are **two separate skill trees**. Do not confuse them.

| Tree | Path | Deployed? | Holds |
|---|---|---|---|
| Repo-scoped | `.agents/skills/<name>/` | **No** (git-tracked, read in place by the agent) | Config-related skills: `apple-design`, `neovim-config`, `chezmoi-migration` |
| Global | `dot_agents/skills/exact_<name>/` | Yes → `~/.agents/skills/<name>/` | Generic agent skills shared across projects: `agent-mailbox`, `grill-me`, etc. |

- **Config-related skill** (how to edit this repo's configs) → `.agents/skills/<name>/`. Never deployed; the agent reads it straight from the source dir. Example: `neovim-config`.
- **Generic agent skill** (workflow, not repo-specific) → `dot_agents/skills/exact_<name>/`. Deploys to the global `~/.agents/skills/`.
- Do NOT put config-related skills under `dot_agents/`; they would leak to the global tree.
- The two trees answer different questions. When adding a skill ask: *does it describe this repo's configs, or is it a reusable workflow?* Config → `.agents/`; workflow → `dot_agents/`.
- Moving a skill between trees leaves a **global stale copy** behind (see below). Deleting the source in `dot_agents/` does not remove `~/.agents/skills/<name>/` on machines that already applied it — ship a `remove_<name>` placeholder to clean it up.

## Deletions Do Not Propagate

**Deleting a chezmoi-tracked source file does NOT delete the target on disk.**
Removing `dot_config/<app>/foo.toml` from the source only stops chezmoi from
managing it; the file stays at `~/.config/<app>/foo.toml`. The same applies to
`~/.agents/skills/<name>/`: if a global skill is removed from `dot_agents/`,
the deployed copy lingers on machines that applied the old state.

Two ways to clean up a leftover target:

1. **`remove_` placeholder** — add an empty source file named `remove_<target>`.
   On apply, chezmoi removes the target if it exists (file/symlink, or a
   directory if empty; non-empty dirs are skipped). Example:
   `dot_agents/skills/remove_chezmoi-migration` removes the deployed global
   `~/.agents/skills/chezmoi-migration` that once shipped via
   `dot_agents/skills/exact_chezmoi-migration`. Prefer this for pure deletions
   (a file/dir that should simply be gone).
2. **Migration changelog** — for complex changes (config content migration,
   per-environment adjustments, moving state around), record a
   `changelogs/YYYY-MM-DD-<slug>.md` entry and apply it via the
   `chezmoi-migration` skill when the user says "更新一下" / "apply 一下". Use
   this when a plain `remove_` cannot express what must happen.

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

## Gotchas

Pitfalls that cost real time in this repo. For the full conceptual model
(prefixes, deployment semantics, data flow), read `.agents/reference/chezmoi.md`
when a chezmoi concept is unclear or a command does something unexpected — the
answers there were each paid for by a real bug.

- **`.tmpl` rename keeps the target path.** Turning `foo.toml` into
  `foo.toml.tmpl` (to add a `{{ }}`) changes the *source*, not the
  destination. Consumers that `require`/import by destination path (wezterm
  `require("config.appearance")`, nvim `exact_lua/...`) keep working. Use
  `git mv` so history tracks the rename.
- **`exact_` and `remove_` on the same target = inconsistent state.** chezmoi
  refuses to guess between "manage this dir" and "delete this target". When
  retiring a global skill: delete the `exact_<name>` source *and* add
  `remove_<name>` in the same commit — never leave both pointing at one
  target. Verify with `chezmoi status | grep <name>` (empty = clean).
- **`chezmoi data` reads the cached config.** After editing `.chezmoi.toml.tmpl`
  (e.g. `[data.font]`), the running config is stale until `chezmoi init`
  regenerates it. `chezmoi init` needs a TTY for its prompts; feed the
  existing `data.*` values or run it interactively.
- **Deleting a source file leaves the target behind** — see
  [Deletions Do Not Propagate](#deletions-do-not-propagate). Always ask what
  happens to the on-disk target when removing a managed file.

## Testing

After changes:
1. `chezmoi diff` — review what will change
2. `chezmoi apply --dry-run --verbose` — verify targets
3. `chezmoi apply` — deploy
4. Verify the app actually works (e.g. open lazygit and press `C`)
