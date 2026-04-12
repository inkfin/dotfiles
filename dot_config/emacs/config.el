;;; config.el --- Tracked configuration defaults -*- lexical-binding: t; -*-
;;; Commentary:
;;
;; This file is intended to be tracked by chezmoi.  It should describe the
;; defaults that you want on every machine, while avoiding machine-specific
;; secrets and per-host toggles.
;;
;; The companion `local.el' is loaded after this file and should only override
;; values that are intentionally machine-local, such as which languages to
;; enable, whether to activate EAF on a specific workstation, or where private
;; auth files live.
;;
;; Keep this file declarative.  Avoid package bootstrapping or large functions
;; here; put reusable logic in `lisp/cfg-core.el' and put package behavior in
;; `lisp/plugins/'.
;;
;;; Code:

(defconst cfg/is-mac (eq system-type 'darwin)
  "Whether the current Emacs is running on macOS.")

(defconst cfg/is-linux (eq system-type 'gnu/linux)
  "Whether the current Emacs is running on GNU/Linux.")

(defconst cfg/is-windows (memq system-type '(ms-dos windows-nt cygwin))
  "Whether the current Emacs is running on a Windows platform.")

;; UI defaults shared across machines.
(defvar cfg/default-frame-width 110
  "Default frame width in character columns.")

(defvar cfg/default-frame-height 36
  "Default frame height in character rows.")

(defvar cfg/scrolloff 5
  "Minimum number of screen lines to keep above and below point.

This mirrors Neovim's `scrolloff` behavior as closely as Emacs allows via
`scroll-margin'.  Keeping it in tracked config makes the intended motion feel
obvious and easy to align across editors.")

(defvar cfg/sidescrolloff 8
  "Minimum number of screen columns to keep around point horizontally.

This tracks the Neovim `sidescrolloff` value used in `nvim.mini`.")

(defvar cfg/default-theme 'modus-vivendi
  "Theme loaded during startup.

Use a built-in theme by default to keep the base UI stable and low maintenance.")

(defvar cfg/windows-font "Sarasa Term SC Nerd Font-15:weight=medium"
  "Default Windows font string.")

(defvar cfg/mac-font "JetBrainsMono Nerd Font Mono-15:weight=medium"
  "Default macOS font string.")

(defvar cfg/linux-font nil
  "Default Linux font string.

Nil means do not force a font from the shared tracked config.")

(defvar cfg/org-pretty-table-charset "╒╕╘╛╤╡╧╞╪═│"
  "Box-drawing characters used by `org-pretty-table-mode'.")

;; Feature toggles.  Keep defaults conservative and lightweight.
(defvar cfg/enable-dashboard t
  "When non-nil, show the dashboard in graphical sessions.")

(defvar cfg/enable-email t
  "When non-nil, load mail defaults.

Mail setup is still lazy and will not initialize SMTP until needed.")

(defvar cfg/enable-eaf nil
  "When non-nil, expose the EAF loader command when the checkout exists.")

;; Language activation is opt-in.  Nothing is enabled by default so a new
;; machine does not pull in language-specific packages or expect external
;; servers that are not installed yet.
(defvar cfg/enabled-languages '()
  "List of language groups enabled on this machine.

Each symbol activates a bounded slice of behavior.  Supported values are:

- `python'
- `web'
- `go'
- `rust'
- `c-cpp'
- `json'
- `yaml'
- `shell'
- `java'

The list is intentionally empty by default.  Enable languages in `local.el'
after their external toolchains are present on the machine.")

;; Mail defaults.  These are safe to track because they are account identifiers
;; rather than secrets.  Secrets themselves should stay in authinfo or other
;; local secret stores.
(defvar cfg/auth-sources '("~/.config/emacs/config/authinfo")
  "Auth source files used by mail and other secret-aware features.")

(defvar cfg/user-full-name "inkfin"
  "Default full name used by mail composition commands.")

(defvar cfg/user-mail-address "inkfin@qq.com"
  "Default mail address used by mail composition commands.")

(defvar cfg/smtp-user "inkfin@qq.com"
  "SMTP username.")

(defvar cfg/smtp-server "smtp.qq.com"
  "SMTP host.")

(defvar cfg/smtp-service 465
  "SMTP port.")

(defvar cfg/smtp-stream-type 'ssl
  "SMTP transport security mode.")

(provide 'config)
;;; config.el ends here
