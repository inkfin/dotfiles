# Chezmoi Reference

How chezmoi actually behaves in this repo. Read this when a concept is
unclear or a command does something unexpected — the answers below were each
paid for by a real bug. Source of truth is `chezmoi.io`; this page caches the
repo-specific answers.

## Source state and target mapping

- Source dir: `~/.local/share/chezmoi` (this repo). Target dir: `$HOME`.
- A source file maps to a target path by stripping prefixes and the `.tmpl`
  suffix, then replacing `dot_` with `.`. `dot_config/foo.toml.tmpl` →
  `~/.config/foo.toml`.
- **`chezmoi source-path <target>`** → source file for a target. **`chezmoi
  target-path <source>`** → target for a source file. Use these to check
  mapping instead of guessing.
- `chezmoi managed` lists everything chezmoi tracks. `chezmoi status` shows
  what would change. `chezmoi unmanaged` shows files on disk not managed.

## Prefixes (source file attributes)

| Prefix | Effect |
|---|---|
| `dot_` | target name gets a leading `.` |
| `exact_` | target dir is exactly synced: anything not in source is **deleted** |
| `create_` | create target once; if target already exists, leave it unchanged |
| `modify_` | target is a script that rewrites an existing file (stdin → stdout); a line `chezmoi:modify-template` switches to template mode |
| `remove_` | **delete the target** if it exists (file/symlink, or empty dir) |
| `symlink_` | target is a symlink; source content = link destination (trailing newline stripped) |
| `executable_` | target gets `+x` |
| `private_` | target permissions cleared of group/world |
| `readonly_` | target permissions cleared of write bits |
| `empty_` | keep the target even if empty (empty files are otherwise removed) |
| `encrypted_` | source file is encrypted |
| `run_` / `once_` / `onchange_` | target is a script, run at apply; `once_` runs only if not run successfully before, `onchange_` only when contents changed; combine with `before_`/`after_` for ordering |
| `.tmpl` | Go template, rendered before writing |

Prefixes combine in a fixed order. `chezmoi chattr` can change attributes
without renaming.

## Application order

chezmoi applies deterministically: `run_before_` scripts (alphabetical),
then entries in alphabetical order of target name (directories before their
contents), then `run_after_` scripts. Target names are compared after all
attributes are stripped. Scripts run in their equivalent destination dir.

## The big gotcha: deletions do not propagate

**Removing a source file stops chezmoi managing the target — it does NOT
delete the target on disk.** The file stays where it was. This is the #1
surprise in this repo.

Cleanup of a leftover target, two ways:

1. **`remove_` placeholder** — add an empty source file named
   `remove_<target-basename>`. On apply, chezmoi removes the target if it
   exists (file or symlink, or a directory **only if empty**; non-empty dirs
   are skipped). Example: `dot_agents/skills/remove_chezmoi-migration` deletes
   `~/.agents/skills/chezmoi-migration`. Good for pure deletions.
2. **Migration changelog** — `changelogs/YYYY-MM-DD-<slug>.md`, applied via
   the `chezmoi-migration` skill on "更新一下" / "apply 一下". For changes a
   `remove_` cannot express (config migration, per-env adjustment).

`exact_` and `remove_` on the **same target** = inconsistent state; chezmoi
errors and refuses. Pick one per target.

## The two skill trees

- `.agents/skills/<name>/` — repo-scoped, git-tracked, **not deployed**.
  Config-related skills (this repo's own conventions). Agent reads the
  source dir directly.
- `dot_agents/skills/exact_<name>/` — deployed to `~/.agents/skills/<name>/`.
  Generic skills shared across projects. `exact_` means removing the source
  removes the deployed copy on the next apply.

Moving a skill between trees leaves the old deployed copy behind on machines
that applied the old state (deletions do not propagate) — ship a `remove_`
placeholder to clean it.

## Special files and directories

| Path | Purpose | In this repo |
|---|---|---|
| `.chezmoiignore` | patterns/OS blocks to exclude from managing; excluded targets stay on disk. Per-directory files apply only to their own dir (see AGENTS.md for when to localize vs keep global) | yes — root OS/profile blocks + per-dir Rime/rime-ls |
| `.chezmoidata.toml` | data for `{{ .xxx }}` keys | yes — `[external]` keys |
| `.chezmoiexternals/*.toml` | external sources (git repos, archives) fetched at apply | yes — doomemacs, rime, tmux, etc. |
| `.chezmoitemplates/` | named template fragments, included via `include` | empty |
| `.chezmoiscripts/` | `run_`/`once_`/`onchange_` scripts | empty |
| `.chezmoi.toml.tmpl` | template that renders the config on `chezmoi init` | yes — also holds `[data.font]` |

`.chezmoiexternals/<name>.toml` example:

```toml
[".local/doomemacs"]
    type = "git-repo"
    url = "https://github.com/doomemacs/doomemacs.git"
    exact = true
    refreshPeriod = "168h"
```

## Additional features (not used in this repo)

Worth knowing about even though this repo does not use them yet.

- **`.chezmoiremove`** — a source file listing targets to delete. Treated as a
  template whether or not it has a `.tmpl` suffix; each rendered line is a
  target path chezmoi removes on apply. **Placement**: like `.chezmoiignore`,
  it works in any directory — one per dir, and paths are relative to the
  file's own directory (a `sub/.chezmoiremove` containing `.old_file` removes
  `~/.old_file`-in-`sub`, i.e. `sub/.old_file`). Lines support `#` comments
  and `!` to exclude. A whole-file alternative to `remove_` prefixes — useful
  for a "cleanup manifest" that keeps growing.
- **`.chezmoiroot`** — lets the source state live in a subdirectory instead of
  the source root. Read before everything else; point it at a relative path.
  Used when chezmoi source is nested inside a bigger git repo. (Warning: all
  other source-root files like `.chezmoi.toml.tmpl` must move under the new
  root.)
- **`.chezmoiversion`** — declares the minimum chezmoi version required to
  interpret the source state (e.g. `2.50.0`). Evaluated before any operation;
  if the installed chezmoi is older, it refuses. Use when a config starts
  depending on a newer chezmoi feature.
- **Encryption** — `encrypted_` prefix + `chezmoi encrypt`/`decrypt`/`age-keygen`,
  with age or gpg backends. Keeps secrets in the source repo without plaintext.
  Not used here; secrets stay out of the tree entirely.
- **Password managers** — chezmoi can source values from 1Password, Bitwarden,
  pass, Vault, etc. via template functions (`{{ onepassword ... }}` etc.).
  Replaces hardcoded secrets in templates.
- **`symlink` mode** — `mode = "symlink"` makes apply create symlinks to the
  source tree instead of copying, for all eligible regular files. Different
  philosophy from this repo's explicit `symlink_` per-file approach.
- **`chezmoi import` / `--one-shot`** — `import` brings an existing dotfile
  into the source state; `init --one-shot` applies then purges chezmoi itself
  (used in containers/VMs).

## Data and config

- `.chezmoi.toml.tmpl` renders to `~/.config/chezmoi/chezmoi.toml` on
  `chezmoi init`. `prompt*Once` functions only fire when the value is missing;
  re-running init reuses existing `data.*`. Non-interactively, `chezmoi init
  --promptDefaults` answers prompts with their defaults (a TTY is otherwise
  required).
- **`chezmoi data` reads the cached `chezmoi.toml`, not the template.** After
  editing `.chezmoi.toml.tmpl` (e.g. `[data.font]`), the running config is
  stale until `chezmoi init` regenerates it.
- `.chezmoidata.toml` provides `{{ .external.xxx }}`-style keys referenced by
  templates.
- Fonts are centralized in `[data.font]` (`term_font`, `editor_font`,
  `ui_font`, `cjk_font`) because nerd font names differ per machine. Apps
  reference `{{ .font.xxx }}`; change one machine by editing
  `~/.config/chezmoi/chezmoi.toml` `[data.font]`.
- **Headless profiles omit `[data.font]`, and chezmoi renders with
  `missingkey=error`** — the error fires at the *lookup*, so `{{ if .font }}`
  and `{{ with .font }}` fail exactly like `{{ .font.x }}`. Guard with
  `{{ dig "font" "editor_font" "monospace" . }}` (lookup + default in one
  call) or `hasKey . "font"`. GUI-only files need no guard: they are
  chezmoiignored on headless profiles and never render.

## Templates

- `{{-` trims whitespace. OS: `{{ if eq .chezmoi.os "windows" }}`. Profile:
  compose on the name — `{{ if hasSuffix "work" .profile }}` /
  `{{ if hasPrefix "server" .profile }}` (see AGENTS.md → Profiles).
- **`{{ }}` inside a comment is still executed.** Every `.tmpl` file is a Go
  template, including `.chezmoi.toml.tmpl` itself. A commented-out
  `{{ .font.xxx }}` fails with `map has no entry for key "xxx"`. Write example
  placeholders as `font.xxx` (no braces) or escape them.
- `.tmpl` rename keeps the target path: turning `foo.toml` into `foo.toml.tmpl`
  changes only the source, so consumers that import by destination path
  (wezterm `require("config.appearance")`, nvim `exact_lua/...`) keep working.

## Verification commands

```zsh
chezmoi diff                          # what will change
chezmoi apply --dry-run --verbose     # verify targets
chezmoi apply                         # deploy
chezmoi status                        # pending changes
chezmoi managed                       # what is tracked
chezmoi verify                        # assert target == source state
chezmoi source-path <target>          # resolve a target to its source
chezmoi execute-template < file.tmpl  # render one template
chezmoi data                          # dump template data
chezmoi update                        # pull latest from the source repo
chezmoi merge                         # merge conflicts between source and target
```

After template edits: `chezmoi data` may be stale — regenerate with
`chezmoi init --promptDefaults` (non-interactive) or interactively.
