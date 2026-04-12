# Emacs Configuration

This configuration targets Emacs 30+ with three explicit priorities:

- fast startup, especially on Windows
- modern built-in or native-feeling completion and LSP workflows
- a clear split between tracked defaults and machine-local toggles

The last point is now a first-class design constraint rather than an afterthought. The config is structured so chezmoi-tracked decisions live in one place, local host-specific toggles live in another, and the package modules consume both through a narrow shared API.

## File Roles

- [early-init.el](./early-init.el)
  Boot-time tuning only. This file exists to affect startup before normal package loading begins. It handles GC, file-name handler suppression during startup, and low-level Windows performance settings.
- [init.el](./init.el)
  Runtime entrypoint. This file loads the tracked settings, then the local overrides, then the shared helper layer, and finally the feature modules.
- [config.el](./config.el)
  Tracked defaults intended to live in chezmoi. This is where shared settings belong: fonts, theme choice, frame size, baseline feature toggles, mail account identifiers, and the default empty list of enabled language groups.
- [local.el](./local.el)
  Machine-local overrides. This file is intentionally minimal and safe by default. No language groups are enabled here initially, so fresh machines do not install extra language packages or expect missing external servers.
- [lisp/cfg-core.el](./lisp/cfg-core.el)
  Shared helper functions for warning management, font selection, language toggle checks, and dependency-aware Eglot startup.
- [lisp/packages-config.el](./lisp/packages-config.el)
  Package bootstrap, archive refresh policy, `use-package` defaults, and module loading order.
- [lisp/plugins](./lisp/plugins)
  Feature modules. Each module is responsible for one coherent editor area rather than mixing concerns.

## Load Order

The exact load order matters:

1. `early-init.el` runs first.
2. `init.el` adds `lisp/` and `lisp/plugins/` to `load-path`.
3. `config.el` loads tracked defaults.
4. `local.el` optionally overrides those defaults.
5. `lisp/cfg-core.el` provides helper functions that depend on values from `config.el` and `local.el`.
6. `lisp/packages-config.el` bootstraps packages and loads the feature modules.

This order is deliberate because it prevents package modules from needing to guess whether the user intended a tracked or local value.

## Startup Model

The startup model is intentionally split between `early-init.el` and `init.el`.

### What belongs in `early-init.el`

- package activation suppression
- temporary GC expansion
- temporary `file-name-handler-alist` suppression
- early frame chrome defaults
- Windows-specific low-level startup settings
- process I/O tuning such as `read-process-output-max`
- redisplay/startup tunables such as `bidi-inhibit-bpa`
- font-cache and file-case behavior tunables used only for startup smoothness

### What belongs in `init.el`

- coding systems
- modifier keys
- core editing defaults
- hooks for line numbers and folding
- frame geometry
- loading tracked config, local config, and modules

This split matters because many startup “optimizations” placed in `init.el` are already too late to help first-frame performance.

## Platform Compatibility

This config is designed to run on Windows, Linux, and macOS, but the platform
layers are intentionally asymmetric because the performance traps are not the
same on each system.

### Windows

Windows gets the most explicit tuning:

- `w32-get-true-file-attributes` disabled
- `w32-pipe-read-delay` set to `0`
- `w32-pipe-buffer-size` increased
- `w32-alt-is-meta` enabled
- left Windows key mapped to `super`
- apps/menu key mapped to `hyper`
- `w32-register-hot-key [s-]` used so a bare Super chord stays available to
  Emacs instead of being consumed unpredictably by the OS

### macOS

macOS gets only modifier normalization in `init.el`:

- Command -> `super`
- Option -> `meta`
- right Control -> `alt`

No macOS-specific startup hacks are currently applied, which is deliberate. The
config only carries platform-specific code where there is a clear performance or
interaction reason.

### Linux

Linux remains the least opinionated platform:

- no tracked font is forced by default
- no Linux-specific process or window-system hacks are applied
- UTF-8 selection coding is enabled normally

This keeps the Linux path conservative and avoids overfitting the config to one
desktop environment or one distribution.

## Startup Tricks Now Documented

Some startup settings previously lived only in code and were easy to miss if
you did not read `early-init.el` carefully. They are now part of the documented
design:

- `read-process-output-max` is increased to improve language-server and process
  throughput
- `process-adaptive-read-buffering` is disabled to reduce latency spikes in
  process-heavy workflows
- `bidi-inhibit-bpa` is enabled to avoid unnecessary bidirectional-paragraph
  analysis during redisplay
- `inhibit-compacting-font-caches` is enabled to reduce font-cache churn,
  especially in GUI sessions with larger font sets
- `auto-mode-case-fold` is disabled so file mode detection does not do
  unnecessary case-folding work at startup

These are not random tweaks. Each of them exists because it changes a known
startup or process bottleneck without materially changing the user's editing
model.

## Package Bootstrap Details

Package startup also has a few deliberate choices that are easy to overlook if
you only read the higher-level package declarations:

- `package-quickstart` is enabled so package autoload metadata is consolidated
  for faster startup
- `package-native-compile` is enabled so installed packages are native-compiled
  when supported by the current Emacs build
- package archive metadata is refreshed only when missing or stale, instead of
  on every launch

These settings live in [lisp/packages-config.el](./lisp/packages-config.el) and
are part of the startup-performance story just as much as `early-init.el`.

## Settings Model

The settings model is now explicit.

### `config.el`

`config.el` is for values you want to carry across machines. Examples:

- frame size
- preferred theme
- default fonts
- whether dashboard is generally enabled
- mail identity settings

### `local.el`

`local.el` is for per-machine choices. Examples:

- which language groups are active on this workstation
- whether EAF should be exposed on this host
- font overrides for a specific monitor setup
- temporary experimentation flags

The file ships with all language groups disabled by default:

```elisp
(setq cfg/enabled-languages '())
```

That means a fresh environment will not install extra language-mode packages like `go-mode`, `rust-mode`, or `yaml-mode`, and it will not wire Eglot hooks for language groups you have not explicitly turned on.

## Completion Stack

The minibuffer and in-buffer completion stack remains the modernized one introduced in the previous pass:

- `vertico`
- `orderless`
- `marginalia`
- `consult`
- `embark`
- `embark-consult`
- `corfu`
- `cape`
- `yasnippet`

This stack was retained because it aligns with modern Emacs direction and keeps the editor close to built-in completion APIs instead of relying on older parallel ecosystems.

## Vim Motion Alignment

One explicit goal of this config is to keep Evil's editing feel close to the
user's `~/.config/nvim.mini` setup instead of treating Vim emulation as a thin
layer on top of Emacs defaults.

The current alignment points are:

- `C-u` and `C-d` are owned by Evil for half-page scrolling
- wrapped-line vertical motion uses visual lines
- `scroll-margin` is set from `cfg/scrolloff`
- `hscroll-margin` is set from `cfg/sidescrolloff`
- `Esc` clears stale search highlighting in normal state
- `C-h`, `C-j`, `C-k`, and `C-l` move between windows in normal state
- `[q` and `]q` drive Emacs' `next-error` navigation, which covers compilation,
  grep, xref, and diagnostic result buffers
- `Q` is a local quit action via `quit-window`, not a full Emacs exit

This matters because a common failure mode in Emacs Evil setups is getting
“almost Vim” behavior where the keybindings exist but the underlying scrolling
or motion semantics still feel like Emacs.  The config now makes the Vim-style
behavior explicit in `plug-evilmode.el` rather than assuming upstream defaults
will continue to match the desired feel.

## Reference Sources For Vim Parity

This repository now includes [AGENTS.md](./AGENTS.md) to record the local
reference trees used when adjusting Vim-like behavior. That file exists so the
same path and intent do not have to be re-explained in future sessions.

The decision order is:

1. `~/.config/nvim.mini` for intended user-facing behavior
2. installed LazyVim for strong Neovim implementation patterns
3. `~/.local/doomemacs` for strong Emacs/Evil implementation patterns

That distinction is important. `nvim.mini` decides what the editor should feel
like. LazyVim and DoomEmacs are implementation references, not the primary
behavior authority.

## Completion UX Alignment

The in-buffer completion layer now aims for the same practical behavior as the
user's Neovim popup completion stack.

### What changed

- `corfu-popupinfo-mode` is enabled globally
- `C-u` and `C-d` inside the Corfu popup scroll documentation when the
  documentation window is visible
- if documentation is not visible, those keys fall back to normal buffer
  scrolling instead of producing fragile or surprising insert-state behavior
- `C-h` toggles completion documentation, borrowing the discoverable popupinfo
  pattern used by DoomEmacs

### Why this design was chosen

The user's Neovim completion stack treats `C-u` and `C-d` as documentation
scroll keys first, with fallback behavior when no documentation pane is
available. Emacs does not have exactly the same completion architecture, so the
closest robust equivalent is:

- use Corfu's popupinfo extension for documentation
- detect whether the popup is visible
- scroll it directly when present
- otherwise fall back safely instead of relying on brittle universal-argument
  semantics

This keeps the keymap useful while avoiding startup-time dependency assumptions
or insert-mode edge cases.

## Minibuffer And Action-Menu Alignment

The minibuffer stack now has a clearer Vim-oriented control path for Vertico,
Consult, and Embark.

### Vertico

The Vertico candidate list now uses direct movement and file-navigation keys:

- `C-j` -> next candidate
- `C-k` -> previous candidate
- `C-h` -> go up a directory in file prompts, otherwise delete backward
- `C-l` -> enter a directory candidate or accept the current candidate
- `RET` -> directory-aware accept in file prompts

This keeps file selection and picker navigation closer to the user's Neovim
picker muscle memory and removes more of the default minibuffer friction.

### Consult

Consult preview is now standardized on `C-SPC`, matching the more deliberate
preview model used in Doom's Vertico stack instead of relying on fully eager
preview for every picker.

### Embark

Embark now exposes:

- `C-.` for `embark-act`
- `C-;` for `embark-dwim`
- `C-c C-l` for `embark-collect`
- `C-c C-e` for `embark-export`

Embark collect buffers are forced into Evil normal state and get a simple
candidate-list keymap:

- `j` / `k` move through entries
- `RET` acts on the current entry
- `q` quits the collect buffer

That matters because Embark collect buffers are effectively result lists, and
leaving them in a generic Emacs special-mode posture always feels slower for a
Vim-first workflow.

## Leader Layer

This configuration now includes a native Evil-first leader key layer built with
 plain keymaps instead of an extra abstraction package. The goal is to get the
 ergonomic benefit of a Doom-style `SPC` command surface without paying for an
 additional dependency or introducing extra keybinding machinery.

### Binding model

- `SPC` is bound in Evil normal, motion, and visual states
- `C-c SPC` is the non-Evil fallback to the same leader tree
- `which-key` names the leader groups so the tree stays discoverable

Using a native keymap here is intentional. It keeps startup cost low, keeps the
binding behavior obvious when debugging, and avoids another package sitting in
the middle of fundamental key dispatch.

### Current top-level groups

- `SPC b` -> buffer
- `SPC c` -> code
- `SPC f` -> file and config
- `SPC g` -> git
- `SPC o` -> organizer/open
- `SPC p` -> package maintenance
- `SPC s` -> search
- `SPC w` -> window

### Examples

- `SPC b b` -> switch buffer
- `SPC b d` -> kill current buffer
- `SPC c a` -> code action
- `SPC c d` -> diagnostics list
- `SPC c f` -> format buffer
- `SPC c r` -> rename symbol
- `SPC f e` -> open `init.el`
- `SPC f c` -> open `config.el`
- `SPC f l` -> open `local.el`
- `SPC f a` -> open `AGENTS.md`
- `SPC f R` -> open `README.md`
- `SPC g g` -> `magit-status`
- `SPC s b` -> search current buffer
- `SPC s g` -> ripgrep
- `SPC w o` -> `ace-window`
- `SPC w s` / `SPC w v` -> split below / split right

### Design rule

Direct Vim motions remain direct where that is the better interaction:

- `gd`, `gr`, `K`, `]d`, `[d` stay as immediate motion/action keys
- `SPC` is for grouped, discoverable commands and editor control surfaces

That separation matters. If everything is pushed under the leader key, the
result stops feeling like Vim and starts feeling like a command launcher with a
modal editor attached to it. The current layout keeps fast motions fast and
uses the leader for things that benefit from grouping.

## Localleader Layer

The config now also includes a proper localleader layer for mode-specific
actions. This follows the same practical pattern used by Doom-style setups:

- `,` is the fast mode-local prefix in selected Evil buffers
- `SPC m` reaches the same local menu in those buffers

The key idea is that localleader is not global. It exists only where a mode has
enough high-value local actions to justify its own command surface.

### Current localleader targets

- Org buffers
- Magit buffers
- Eglot-managed buffers

### Org localleader

- `, a` archive subtree
- `, d` deadline
- `, l` insert link
- `, s` schedule
- `, t` todo

### Magit localleader

- `, b` checkout branch
- `, c` create commit
- `, f` fetch
- `, g` refresh
- `, p` push
- `, s` stage
- `, u` unstage

### Eglot localleader

- `, a` code action
- `, d` diagnostics list
- `, f` format buffer
- `, h` hover / eldoc
- `, r` rename symbol

### Why both `,` and `SPC m`

`,` is the fast muscle-memory path. `SPC m` is the discoverable path and makes
the leader hierarchy consistent with mode-local actions.

### Important tradeoff

Binding `,` as localleader in these buffers means it overrides Evil's default
reverse-find repeat there. That is a deliberate choice. In mode-heavy buffers
such as Org and Magit, the local action menu is generally more valuable than
the reverse-find repeat command.

## Language and LSP Model

The language model changed substantially in this pass.

### High-level goal

Language support should be opt-in, bounded, and safe on partially provisioned machines.

### What that means operationally

- no language groups are enabled by default
- no language-specific extra packages are installed by default
- Eglot hooks are registered only for enabled language groups
- external dependency failures do not abort startup
- missing toolchains produce warnings only when relevant

### Supported language groups

The current config supports these toggle symbols in `cfg/enabled-languages`:

- `python`
- `web`
- `go`
- `rust`
- `c-cpp`
- `json`
- `yaml`
- `shell`
- `java`

### Example local configuration

```elisp
(setq cfg/enabled-languages '(python web json yaml))
```

That single line activates the language module for those groups and leaves everything else inactive.

### Dependency behavior

Each language group declares the executables it needs. For example:

- `python` expects `pyright-langserver`
- `web` expects `node` and `typescript-language-server`
- `yaml` expects `node` and `yaml-language-server`
- `go` expects `gopls`
- `rust` expects `rust-analyzer`

If the language group is enabled but the executables are missing, the config does not hard-fail. Instead, `lisp/cfg-core.el` emits a warning once and skips starting Eglot for that buffer. This is intentional: on Windows, toolchains often arrive in stages, and the editor should remain usable while those dependencies are still being installed.

## LSP Keymap Alignment

The LSP layer now keeps two interfaces at once:

- conservative `C-c` bindings for discoverability and non-Evil use
- Vim-style normal-state bindings for the actual editing path

### Managed-buffer Vim bindings

When Eglot is active in a buffer, the following normal-state bindings are
installed in that buffer:

- `gd` -> definition
- `gD` -> alternate definition jump path in another window
- `gi` -> implementation
- `gr` -> references
- `gt` -> type definition
- `K` -> hover documentation
- `[d` -> previous diagnostic
- `]d` -> next diagnostic

This mirrors the user's `nvim.mini` setup much more closely than the previous
pure-`C-c` layout.

### Noise reduction choices

The Eglot layer also sets:

- `eglot-auto-display-help-buffer` to `nil`
- `eglot-events-buffer-size` to `0`

These follow the same general principle used elsewhere in the config: avoid
background UI churn and preserve responsiveness, especially on Windows.

## Diagnostics And Result Lists

Diagnostics now have a cleaner split between symbol navigation and list
navigation.

### Symbol-level diagnostics

- `]d` -> next diagnostic
- `[d` -> previous diagnostic

These bindings are installed both for Eglot-managed buffers and, more
generally, on `flymake-mode-map`, so they continue to work in Flymake-backed
buffers even when Eglot is not involved.

### Diagnostic list buffers

Flymake diagnostics buffers now start in Evil normal state and use:

- `j` / `k` to move
- `RET` to jump to the selected diagnostic
- `q` to close the diagnostics buffer
- `[d` / `]d` to keep stepping through diagnostics

That keeps the diagnostic list usable as a transient navigation panel instead
of forcing a special-mode interaction style.

### Generic result lists

- `]q` / `[q` continue to use Emacs' `next-error` navigation stack

This is intentionally broader than diagnostics alone. In Emacs, the same stack
drives compilation results, grep matches, xref results, and several other
navigable result buffers, so keeping `q`-motions attached to that generic
mechanism is the cleanest analogue to Neovim quickfix movement.

## Magit Alignment

This pass also adds an explicit Magit module instead of leaving Git UI behavior
to package defaults alone.

### What was added

- `magit` is now a config-managed top-level package
- `C-x g` opens `magit-status`
- `evil-collection` still provides broad Magit mode coverage
- a small set of high-value Vim-oriented overrides are added on top

### Magit motion and action normalization

In Magit buffers, the config now provides:

- `q` -> `quit-window`
- `Q` -> bury the current Magit buffer
- `gr` -> refresh
- `gR` -> refresh all
- `zt`, `zz`, `zb` -> standard viewport recenter motions
- `[` / `]` -> previous/next Magit section sibling
- `gd` in diff buffers -> jump between diffstat and diff body

The purpose is not to replace Magit's own model. It is to smooth the highest
friction points so Magit behaves like a serious Vim-aware tool instead of a
special mode that merely happens to support Evil.

## Why Missing Dependencies Only Warn

This behavior is deliberate and pragmatic.

A hard failure is appropriate when the editor cannot continue safely. That is not the case here. If `node` or a language server is missing, the correct fallback is usually:

- keep basic editing working
- keep completion working where possible
- warn clearly about what is missing
- avoid repeating the same warning constantly

That is why `cfg/warn-once` and `cfg/ensure-dependencies-or-warn` exist in [lisp/cfg-core.el](./lisp/cfg-core.el).

## Package Installation Policy

The package installation policy is now stricter:

- shared editor packages are installed regardless of language toggles
- language-mode packages are installed only when their language group is enabled
- built-in modes stay preferred when they are good enough

Concrete example:

- `yaml-mode` installs only when `yaml` is enabled
- `go-mode` installs only when `go` is enabled
- `rust-mode` installs only when `rust` is enabled

This keeps a default machine lean and avoids package churn for ecosystems you are not actively using.

## Optional Integrations

### Dashboard

Dashboard remains enabled by default in graphical sessions, but it now respects `cfg/enable-dashboard`, so a specific machine can disable it in `local.el` without touching the tracked config.

### EAF

EAF is now doubly gated:

- `cfg/enable-eaf` must be non-nil
- the local EAF checkout directory must exist

Even then, EAF is not loaded at startup. The config exposes an on-demand loader command on `C-c e`, which keeps EAF available without paying startup cost on every Emacs launch.

## Windows Notes

This configuration is intentionally conservative about Windows performance pitfalls.

The most important current choices are:

- startup suppression of `file-name-handler-alist`
- disabled `w32-get-true-file-attributes`
- zero `w32-pipe-read-delay`
- increased `w32-pipe-buffer-size`
- increased `read-process-output-max`
- disabled `process-adaptive-read-buffering`
- lazy language activation
- warning-based dependency fallback instead of startup failure

The last two matter more than they may appear to at first glance. A Windows setup with no language groups enabled stays lightweight and robust, even if Node, Go, Rust, or Java are not installed yet.

One more Windows-specific detail now documented explicitly: `init.el` registers
`[s-]` with `w32-register-hot-key`. This is not a generic cross-platform Emacs
setting. It exists only to preserve a usable Super modifier path on Windows,
where the OS is otherwise eager to consume Windows-key combinations.

## How To Enable a Language

1. Install the external server and any prerequisite runtime.
2. Add the language symbol to `cfg/enabled-languages` in [local.el](./local.el).
3. Restart Emacs.

Example:

```elisp
(setq cfg/enabled-languages '(python c-cpp))
```

If the executable is still missing, Emacs will warn once when the relevant mode activates and continue without LSP instead of breaking the session.

## Maintenance Guidance

When extending this config:

- put boot-time mechanics in `early-init.el`
- put tracked defaults in `config.el`
- put host-specific overrides in `local.el`
- put shared helper logic in `lisp/cfg-core.el`
- put package behavior in focused modules under `lisp/plugins`
- keep language support grouped by language toggle, not by random package additions
- prefer warnings and safe degradation for optional external dependencies

That separation is what keeps the config understandable as it grows.

## Package Maintenance Workflow

This configuration now includes a built-in package audit layer in [lisp/cfg-maintenance.el](./lisp/cfg-maintenance.el).

The maintenance model is intentionally config-driven:

- start from the top-level packages the config explicitly manages
- add language-specific top-level packages only for language groups enabled in `local.el`
- expand that set through installed package dependencies
- treat anything outside that closure as orphaned

This is stricter and more reliable than manually scanning `elpa/` or trying to remember which old package belonged to a previous stack.

### Commands

- `C-c p a`
  Run `cfg/package-audit-report` and open a report buffer.
- `C-c p p`
  Run `cfg/package-prune-orphans` and remove orphaned packages after confirmation.
- `C-c p s`
  Run `cfg/update-package-selected-packages` and sync `package-selected-packages` to the config-managed top-level package set.

### What the audit shows

The audit buffer includes:

- config-managed top-level packages
- installed dependency closure
- installed external packages
- orphaned packages

That makes it easy to reason about whether a package is present because the
current config wants it, because another required package depends on it, or
because it is leftover drift from an old setup.

### Why pruning is conservative

Pruning happens in dependency-safe order. The code prefers deleting leaf
packages first so `package-delete` does not fail because one orphan still
depends on another orphan that has not been removed yet.

The prune command is interactive on purpose. Package deletion is still a
destructive action, even when the orphan computation is sound.
