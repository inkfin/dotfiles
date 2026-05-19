---
name: neovim-config
description: Edit and maintain the user's Neovim configuration when working on plugin setup, keymaps, LSP, UI, startup performance, or config migration. Use when Codex needs to change either of the user's two active Neovim configs (`nvim.lazyvim` and `nvim.mini`), reconcile live config with chezmoi-managed source, handle `.tmpl` files, or inspect the locally installed LazyVim checkout as a reference implementation.
---

# Neovim Config

Edit the user's Neovim configs with chezmoi-aware workflows, while using the local runtime config and installed LazyVim checkout to verify behavior and borrow patterns.

## Workflow

1. Identify which config is in scope.
   On this machine, the active working dirs are typically `~/.config/nvim.mini` and `~/.config/nvim.lazyvim`.
   The chezmoi source of truth is `~/.local/share/chezmoi`.
   The managed source dirs are `~/.local/share/chezmoi/dot_config/nvim.mini` and `~/.local/share/chezmoi/dot_config/nvim.lazyvim`.

2. Resolve whether the target is chezmoi-managed.
   Use chezmoi commands instead of guessing from filenames alone.
   Prefer checks such as `chezmoi managed <path>`, `chezmoi source-path <path>`, and `chezmoi diff`.
   If chezmoi manages the file, edit the corresponding source file returned by chezmoi.
   If the source file is a `.tmpl`, treat that template as authoritative.
   Expect chezmoi naming such as `dot_config/...`, `exact_lua/...`, `symlink_*.tmpl`, `create_*.tmpl`, and other template-driven paths.

3. Use the live Neovim config as runtime context.
   Read the actual live config under `~/.config/...` when verifying current behavior, plugin loading, lockfiles, generated output, or local drift.
   Do not assume the live file is the right edit target just because it looks like a normal file outside the chezmoi tree. Chezmoi may have rendered it from a template.

4. Use installed LazyVim only as a reference.
   Inspect the local LazyVim checkout for upstream defaults, keymaps, extras, and plugin patterns.
   On this Windows machine, the installed LazyVim reference path is `~/AppData/Local/nvim-data/lazy/LazyVim`.
   On other platforms, resolve the equivalent from Neovim's data dir and look for `lazy/LazyVim` under that location.
   Do not edit the installed LazyVim checkout unless the user explicitly asks for that.

## Path Rules

When a user asks to edit Neovim config, check in this order:

1. Live target file the user is talking about
2. `chezmoi managed <live-path>`
3. `chezmoi source-path <live-path>` to find the real source file
4. Live runtime file in `~/.config/nvim.mini` or `~/.config/nvim.lazyvim` for behavior verification
5. Installed LazyVim reference in the platform-specific data dir

If the target config is ambiguous, infer it from surrounding filenames, plugin style, or user wording before asking.
Use `nvim.mini` for fast-startup, native `vim.pack`, and minimalist plugin architecture.
Use `nvim.lazyvim` for LazyVim-specific behavior, extras, or parity checks against previous setup.

## Editing Rules

Inspect before editing. Read nearby plugin/config files so changes match local conventions.

Prefer detailed comments when editing Neovim config.
When behavior is non-obvious, add or expand comments that explain what Neovim will do at runtime, why the setting or mapping exists, what triggers it, and any relevant load-order, fallback, or integration details.
Do not leave comments at a vague summary level if the code is encoding important editor behavior.
When modifying existing config, review nearby comments and update or remove stale ones so comments continue to match actual behavior.
If a comment and code disagree, fix the comment as part of the same change instead of leaving drift behind.

Preserve the config's existing architecture:

- `nvim.mini` uses native `vim.pack` and a simpler hand-rolled structure.
- `nvim.lazyvim` follows LazyVim conventions and may mirror upstream plugin specs.

When porting ideas from LazyVim into `nvim.mini`, adapt them to the local architecture instead of copying LazyVim patterns verbatim.

When touching plugin mappings or behavior, check both:

- the local plugin config that currently owns the keymap or feature
- the LazyVim reference if the user mentions previous LazyVim behavior or wants parity

## Chezmoi Rules

Treat `.tmpl` files as executable source, not plain text copies.
Preserve template expressions and profile conditionals.
Avoid deleting template logic unless the requested change explicitly removes that behavior.

Use chezmoi as the canonical sync mechanism:

- prefer `chezmoi edit <live-path> --apply` when making source-first changes
- use `chezmoi diff` to inspect drift between source and live files
- use `chezmoi source-path <path>` to locate the real editable source
- use `chezmoi re-add <live-path>` only when a live managed file was edited directly and those changes must be pulled back into source
- use `chezmoi apply <live-path>` or `chezmoi apply` when the user wants the rendered config updated

If the live config and chezmoi source differ, prefer updating the chezmoi source and mention the drift in the final response.

## Commits

Follow the user's existing commit style when asked to commit changes.
In this repo, prefer concise messages like `mod(nvim.mini): ...` or `mod(nvim.lazyvim): ...`, scoped to the config being changed.
Keep the subject focused on the behavioral change, not the implementation detail.

## Verification

After changes, verify with the cheapest useful checks:

- read back the edited file
- if chezmoi is involved, run `chezmoi diff` for the touched path when useful
- search for conflicting duplicate mappings or plugin declarations
- if relevant, compare with the installed LazyVim reference for expected behavior
- run a lightweight Neovim check only when needed and practical

In the final response, mention whether the edit was applied to chezmoi source, live config, or both, and whether `chezmoi apply` was run.
