# AGENTS.md

## Reference Configs

This Emacs config intentionally aligns editor behavior against three local
reference trees. Future changes that affect Vim motion, completion UX, LSP
navigation, or popup ergonomics should check these paths before changing the
Emacs bindings or semantics.

### Primary behavior target: `nvim.mini`

- Live path: `C:\Users\11096\.config\nvim.mini`
- Role: this is the primary source of truth for the user's expected editing
  behavior.
- Use it for:
  - Vim motion expectations
  - normal/visual/operator keymap semantics
  - completion popup/document scrolling behavior
  - LSP navigation and diagnostics motions
  - search clearing, save, quit, and quickfix motions

When Emacs behavior should "feel right", prefer matching `nvim.mini` first.

### Upstream Neovim ergonomics reference: LazyVim

- Live path: `C:\Users\11096\AppData\Local\nvim-data\lazy\LazyVim`
- Role: installed upstream reference for polished Neovim defaults and plugin
  keymaps.
- Use it for:
  - robust keymap conventions around motions and windows
  - completion/LSP plugin ergonomics
  - fallback behavior when `nvim.mini` only partially overrides LazyVim

Do not edit this tree unless the user explicitly asks to modify LazyVim
itself. It is a reference checkout, not the target config.

### Emacs-side ergonomics reference: DoomEmacs

- Live path: `C:\Users\11096\.local\doomemacs`
- Role: reference for what a polished Evil-first Emacs setup does, especially
  around Evil integration, Corfu popup behavior, and Eglot/LSP ergonomics.
- Use it for:
  - Evil startup variables that must be set before Evil loads
  - escape/search-highlight clearing behavior
  - Corfu popupinfo key handling and insert-state interactions
  - Eglot defaults that reduce noise and avoid unnecessary popup churn

Prefer DoomEmacs as the Emacs-specific implementation reference after behavior
has already been chosen from `nvim.mini`.

## Decision Order

When changing Vim-style behavior in this Emacs config, use this order:

1. `nvim.mini` for intended behavior
2. LazyVim for stronger Neovim ergonomics and plugin conventions
3. DoomEmacs for the cleanest Emacs/Evil implementation strategy

This order matters. The goal is not to copy DoomEmacs or LazyVim blindly. The
goal is to make Emacs feel consistent with the user's main Neovim workflow
while borrowing proven implementation patterns from mature reference configs.
