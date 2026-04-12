;;; cfg-core.el --- Shared helper functions for the config -*- lexical-binding: t; -*-
;;; Commentary:
;;
;; This file holds small reusable helpers that need to be available across
;; multiple modules.  Keeping them here avoids hiding logic inside unrelated
;; package modules and keeps `config.el' mostly declarative.
;;
;;; Code:

(require 'cl-lib)
(require 'subr-x)

(defvar cfg--warning-cache (make-hash-table :test #'equal)
  "Cache used to avoid repeating the same warning message endlessly.")

(defun cfg/default-font ()
  "Return the platform-appropriate default font string, or nil.

The font variables themselves live in `config.el' so they can be tracked and
optionally overridden by `local.el'."
  (cond
   (cfg/is-mac cfg/mac-font)
   (cfg/is-windows cfg/windows-font)
   (cfg/is-linux cfg/linux-font)
   (t nil)))

(defun cfg/language-enabled-p (language)
  "Return non-nil when LANGUAGE is enabled in `cfg/enabled-languages'."
  (memq language cfg/enabled-languages))

(defun cfg/warn-once (key format-string &rest args)
  "Emit a warning identified by KEY only once.

FORMAT-STRING and ARGS follow the same rules as `format'.  This helper is used
for optional external dependencies: missing language servers or toolchains
should not block startup, but the user still needs a clear signal about why a
feature stayed inactive."
  (unless (gethash key cfg--warning-cache)
    (puthash key t cfg--warning-cache)
    (display-warning 'cfg (apply #'format format-string args) :warning)))

(defun cfg/missing-executables (executables)
  "Return the subset of EXECUTABLES that are not available on `exec-path'."
  (cl-remove-if #'executable-find executables))

(defun cfg/ensure-dependencies-or-warn (feature executables)
  "Return non-nil when EXECUTABLES required by FEATURE are available.

If one or more executables are missing, warn once and return nil.  This keeps
optional language support in a soft-failure mode rather than throwing an error
at startup or on first file visit."
  (let ((missing (cfg/missing-executables executables)))
    (if missing
        (progn
          (cfg/warn-once
           (list feature missing)
           "%s support is enabled but inactive because these executables were not found: %s"
           (capitalize (replace-regexp-in-string "-" " " (symbol-name feature)))
           (mapconcat #'identity missing ", "))
          nil)
      t)))

(defun cfg/eglot-ensure-if-ready (feature executables)
  "Start Eglot for FEATURE only when EXECUTABLES are available."
  (when (cfg/ensure-dependencies-or-warn feature executables)
    (when (fboundp 'eglot-ensure)
      (eglot-ensure))))

(defun cfg/load-user-file (filename &optional missing-ok)
  "Load FILENAME from `user-emacs-directory'.

When MISSING-OK is non-nil, ignore a missing file instead of signaling an
error. This keeps the tracked-vs-local file loading pattern explicit and
reusable across the configuration."
  (load (expand-file-name filename user-emacs-directory) missing-ok 'nomessage))

(defun cfg/open-user-file (filename)
  "Open FILENAME from `user-emacs-directory'."
  (interactive)
  (find-file (expand-file-name filename user-emacs-directory)))

(defun cfg/disable-line-numbers ()
  "Disable line numbers in the current buffer."
  (display-line-numbers-mode 0))

(defun cfg/add-hooks (hooks function)
  "Add FUNCTION to each hook in HOOKS."
  (dolist (hook hooks)
    (add-hook hook function)))

(defun cfg/define-keys (keymap bindings)
  "Install BINDINGS into KEYMAP.

BINDINGS should be a list of cons cells where the car is a key string suitable
for `kbd' and the cdr is the target command or keymap."
  (dolist (binding bindings)
    (define-key keymap (kbd (car binding)) (cdr binding))))

(defun cfg/which-key-labels (keymap replacements)
  "Register REPLACEMENTS with which-key for KEYMAP.

REPLACEMENTS should be a flat alternating list of key strings and labels, in
the format expected by `which-key-add-keymap-based-replacements'. The helper is
kept here so keymap configuration can stay declarative without scattering the
same call shape everywhere."
  (when (featurep 'which-key)
    (apply #'which-key-add-keymap-based-replacements keymap replacements)))

(defun cfg/eglot-setup-managed-language (feature hooks mode-spec executables)
  "Register a managed Eglot language group.

FEATURE is the local language-group symbol.
HOOKS is the list of major-mode hook symbols that should trigger setup.
MODE-SPEC is the mode entry to add to `eglot-server-programs'.
EXECUTABLES is the list of required executables.

The setup is intentionally soft-failing: if EXECUTABLES are missing, a warning
is shown once and the buffer remains usable without LSP."
  (add-to-list 'eglot-server-programs mode-spec)
  (cfg/add-hooks
   hooks
   (lambda ()
     (cfg/eglot-ensure-if-ready feature executables))))

(provide 'cfg-core)
;;; cfg-core.el ends here
