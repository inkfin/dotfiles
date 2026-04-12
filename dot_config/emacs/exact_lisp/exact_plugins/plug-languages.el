;;; plug-languages.el --- Opt-in language support and Eglot wiring -*- lexical-binding: t; -*-
;;; Commentary:
;;
;; This module is intentionally organized around language groups rather than
;; packages.  The goal is operational clarity:
;;
;; - the user enables a language group in `local.el'
;; - this module installs only the packages needed for that group
;; - Eglot hooks are registered only for enabled groups
;; - external dependency failures degrade to warnings instead of startup errors
;;
;; This is especially important on Windows, where a new machine often has Emacs
;; available before Node, Go, Rust, or other toolchains are installed.
;;
;;; Code:

(require 'xref)

(setq eglot-autoshutdown t
      eglot-auto-display-help-buffer nil
      eglot-events-buffer-size 0
      eglot-sync-connect nil
      flymake-no-changes-timeout 0.5)

(use-package flymake
  :ensure nil
  :bind
  (:map flymake-mode-map
        ("C-c !" . flymake-show-buffer-diagnostics)
        ("M-n" . flymake-goto-next-error)
        ("M-p" . flymake-goto-prev-error)))

(defun cfg/eglot-format-buffer-on-save ()
  "Format the current buffer on save when managed by Eglot."
  (when (and (bound-and-true-p eglot-managed-mode)
             (derived-mode-p 'prog-mode))
    (add-hook 'before-save-hook #'eglot-format-buffer nil t)))

(add-hook 'eglot-managed-mode-hook #'cfg/eglot-format-buffer-on-save)

(defun cfg/eglot-find-references ()
  "Show references for the symbol at point.

This is separated into a named helper so the Vim-style keymap reads clearly and
stays easy to replace later if the preferred references UI changes."
  (interactive)
  (xref-find-references (thing-at-point 'symbol t)))

(defun cfg/eglot-hover ()
  "Show hover documentation for the current symbol."
  (interactive)
  (eldoc))

(defun cfg/eglot-diagnostic-prev ()
  "Jump to the previous Flymake diagnostic."
  (interactive)
  (flymake-goto-prev-error))

(defun cfg/eglot-diagnostic-next ()
  "Jump to the next Flymake diagnostic."
  (interactive)
  (flymake-goto-next-error))

(defun cfg/eglot-setup-vim-keybindings ()
  "Install Vim-oriented local keybindings for LSP editing.

The global `C-c' bindings remain available for discoverability, but once Eglot
is managing a buffer the primary editing path should feel close to the user's
Neovim configuration: `gd', `gr', `K', `[d', `]d', and related motions should
work directly in normal state."
  (when (featurep 'evil)
    (evil-define-key 'normal eglot-managed-mode-map
      (kbd "gd") #'xref-find-definitions
      (kbd "gD") #'xref-find-definitions-other-window
      (kbd "gi") #'xref-find-implementations
      (kbd "gr") #'cfg/eglot-find-references
      (kbd "gt") #'xref-find-type-definitions
      (kbd "K") #'cfg/eglot-hover
      (kbd "[d") #'cfg/eglot-diagnostic-prev
      (kbd "]d") #'cfg/eglot-diagnostic-next)))

(add-hook 'eglot-managed-mode-hook #'cfg/eglot-setup-vim-keybindings)

(with-eval-after-load 'flymake
  ;; Diagnostics buffers are transient result lists, so normal state is the
  ;; least surprising Evil posture. Keep quitting and following diagnostics on
  ;; obvious keys instead of leaving the user in an Emacs-special-mode pocket.
  (when (featurep 'evil)
    (evil-set-initial-state 'flymake-diagnostics-buffer-mode 'normal)
    (evil-define-key 'normal flymake-diagnostics-buffer-mode-map
      (kbd "j") #'next-line
      (kbd "k") #'previous-line
      (kbd "q") #'quit-window
      (kbd "RET") #'compile-goto-error
      (kbd "[d") #'cfg/eglot-diagnostic-prev
      (kbd "]d") #'cfg/eglot-diagnostic-next))
  ;; Keep diagnostic motions available even when Flymake is active without
  ;; Eglot, so `]d` and `[d` do not silently disappear in non-LSP buffers.
  (define-key flymake-mode-map (kbd "[d") #'cfg/eglot-diagnostic-prev)
  (define-key flymake-mode-map (kbd "]d") #'cfg/eglot-diagnostic-next))

(use-package eglot
  :ensure nil
  :bind
  (:map eglot-mode-map
        ("C-c r" . eglot-rename)
        ("C-c a" . eglot-code-actions)
        ("C-c f" . eglot-format-buffer)
        ("C-c d" . xref-find-definitions)
        ("C-c h" . eldoc)))

;; Built-in languages do not require extra mode packages.  They only need Eglot
;; hooks and server registration, and even that should happen only when the
;; language group is enabled locally.

(dolist (language
         '((python
            :hooks (python-mode-hook python-ts-mode-hook)
            :modes ((python-mode python-ts-mode) . ("pyright-langserver" "--stdio"))
            :executables ("pyright-langserver"))
           (web
            :hooks (js-mode-hook js-ts-mode-hook typescript-ts-mode-hook tsx-ts-mode-hook)
            :modes ((js-mode js-ts-mode typescript-ts-mode tsx-ts-mode)
                    . ("typescript-language-server" "--stdio"))
            :executables ("node" "typescript-language-server"))
           (json
            :hooks (json-mode-hook json-ts-mode-hook)
            :modes ((json-mode json-ts-mode) . ("vscode-json-language-server" "--stdio"))
            :executables ("node" "vscode-json-language-server"))
           (shell
            :hooks (sh-mode-hook bash-ts-mode-hook)
            :modes ((sh-mode bash-ts-mode) . ("bash-language-server" "start"))
            :executables ("node" "bash-language-server"))
           (c-cpp
            :hooks (c-mode-hook c++-mode-hook c-ts-mode-hook c++-ts-mode-hook)
            :modes ((c-mode c++-mode c-ts-mode c++-ts-mode) . ("clangd" "--background-index"))
            :executables ("clangd"))
           (java
            :hooks (java-mode-hook java-ts-mode-hook)
            :modes ((java-mode java-ts-mode) . ("jdtls"))
            :executables ("java" "jdtls"))))
  (pcase-let* ((`(,feature . ,plist) language)
               (hooks (plist-get plist :hooks))
               (mode-spec (plist-get plist :modes))
               (executables (plist-get plist :executables)))
    (when (cfg/language-enabled-p feature)
      (cfg/eglot-setup-managed-language feature hooks mode-spec executables))))

;; These languages need extra major-mode packages, so their declarations are
;; wrapped in plain `when' forms instead of relying on `use-package :if'.  This
;; is intentional: with `use-package-always-ensure', `:if' can still leave
;; surprising package-install behavior during expansion, while an outer `when'
;; keeps disabled language groups completely inert.

(when (cfg/language-enabled-p 'go)
  (use-package go-mode
    :mode "\\.go\\'"
    :hook (go-mode . (lambda ()
                       (cfg/eglot-ensure-if-ready 'go '("gopls"))))
    :config
    (add-to-list 'eglot-server-programs '((go-mode) . ("gopls")))))

(when (cfg/language-enabled-p 'rust)
  (use-package rust-mode
    :mode "\\.rs\\'"
    :hook (rust-mode . (lambda ()
                         (cfg/eglot-ensure-if-ready 'rust '("rust-analyzer"))))
    :config
    (add-to-list 'eglot-server-programs '((rust-mode) . ("rust-analyzer")))))

(when (cfg/language-enabled-p 'yaml)
  (use-package yaml-mode
    :mode "\\.ya?ml\\'"
    :hook (yaml-mode . (lambda ()
                         (cfg/eglot-ensure-if-ready
                          'yaml
                          '("node" "yaml-language-server"))))
    :config
    (add-to-list 'eglot-server-programs
                 '((yaml-mode) . ("yaml-language-server" "--stdio")))))

(provide 'plug-languages)
;;; plug-languages.el ends here
