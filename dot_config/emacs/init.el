;;; init.el --- Main runtime entrypoint for the Emacs config -*- lexical-binding: t; -*-
;;; Commentary:
;;
;; `early-init.el' handles boot-time mechanics such as GC, package startup, and
;; Windows-specific low-level tuning.  This file starts after Emacs has created
;; the initial frame and is responsible for the human-facing editor behavior.
;;
;; The load order is intentional:
;;
;; 1. Core load-path setup
;; 2. Tracked settings from `config.el`
;; 3. Machine-local overrides from `local.el`
;; 4. Shared helper functions from `lisp/cfg-core.el`
;; 5. Package bootstrap and feature modules
;;
;; Keeping that boundary sharp makes it much easier to reason about what should
;; be tracked in chezmoi, what should remain local to a single machine, and what
;; should stay in reusable modules.
;;
;;; Code:

(let ((minver "30.1"))
  (when (version< emacs-version minver)
    (error "This config requires Emacs %s or newer" minver)))

;; Local source directories.  The plugin path is added explicitly so each module
;; can be loaded by feature name without a directory scan.
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "lisp/plugins" user-emacs-directory))

;; Tracked defaults first, then local overrides.
(load (expand-file-name "config.el" user-emacs-directory) nil 'nomessage)
(load (expand-file-name "local.el" user-emacs-directory) t 'nomessage)

(require 'cfg-core)
(require 'cfg-maintenance)

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(unless (file-exists-p custom-file)
  (with-temp-buffer
    (write-file custom-file)))
(load custom-file 'noerror 'nomessage)

;; Platform-specific modifier setup belongs here rather than in `early-init.el'
;; because it affects interactive editing behavior instead of low-level startup.
(when cfg/is-mac
  (setq mac-command-modifier 'super
        mac-option-modifier 'meta
        mac-right-control-modifier 'alt))

(when cfg/is-windows
  (setq w32-alt-is-meta t
        w32-pass-lwindow-to-system nil
        w32-lwindow-modifier 'super
        w32-apps-modifier 'hyper)
  ;; Reserve a bare Super modifier chord for Emacs so Windows does not try to
  ;; reinterpret it as a system shortcut. This call is Windows-only and simply
  ;; does not exist on other platforms.
  (w32-register-hot-key [s-]))

(prefer-coding-system 'utf-8-unix)
(set-language-environment "UTF-8")
(unless cfg/is-windows
  (set-selection-coding-system 'utf-8))

;; Global editing defaults.  These are intentionally grouped in one place so
;; future changes remain discoverable without chasing package declarations.
(setq confirm-kill-emacs #'y-or-n-p
      inhibit-startup-message t
      inhibit-startup-screen t
      inhibit-startup-echo-area-message user-login-name
      initial-scratch-message nil
      ring-bell-function #'ignore
      make-backup-files nil
      auto-save-default nil
      create-lockfiles nil
      use-dialog-box nil
      sentence-end-double-space nil
      scroll-conservatively 101
      scroll-margin cfg/scrolloff
      hscroll-margin cfg/sidescrolloff
      hscroll-step 1
      tab-always-indent 'complete
      completion-ignore-case t
      read-file-name-completion-ignore-case t
      read-buffer-completion-ignore-case t
      display-line-numbers-type 'relative
      frame-resize-pixelwise t
      use-short-answers t)

(setq-default indent-tabs-mode nil
              tab-width 4
              truncate-lines t)

;; `recentf' can become a visible startup cost on Windows because cleanup and
;; path probing are relatively expensive there. Keep its policy explicit and
;; conservative instead of inheriting package defaults.
(setq recentf-auto-cleanup cfg/recentf-auto-cleanup
      recentf-max-saved-items cfg/recentf-max-saved-items
      recentf-max-menu-items cfg/recentf-max-menu-items
      recentf-exclude cfg/recentf-exclude)

(electric-pair-mode 1)
(show-paren-mode 1)
(delete-selection-mode 1)
(savehist-mode 1)
(save-place-mode 1)
(recentf-mode 1)
(when cfg/is-windows
  ;; Windows is the strict path: avoid extra chatter and avoid expensive
  ;; startup cleanup work. Manual cleanup remains available with
  ;; `recentf-cleanup' when needed.
  (setq recentf-keep nil))
(global-auto-revert-mode 1)
(pixel-scroll-precision-mode 1)
(column-number-mode 1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(when (display-graphic-p)
  (scroll-bar-mode -1))
(unless (display-graphic-p)
  (xterm-mouse-mode 1))

(cfg/add-hooks '(prog-mode-hook) #'hs-minor-mode)
(cfg/add-hooks '(prog-mode-hook) #'display-line-numbers-mode)
(cfg/add-hooks '(org-mode-hook
                 term-mode-hook
                 shell-mode-hook
                 eshell-mode-hook
                 vterm-mode-hook
                 pdf-view-mode-hook)
               #'cfg/disable-line-numbers)

(add-to-list 'default-frame-alist `(width . ,cfg/default-frame-width))
(add-to-list 'default-frame-alist `(height . ,cfg/default-frame-height))
(when-let ((font (cfg/default-font)))
  (add-to-list 'default-frame-alist `(font . ,font)))

(require 'keybindings-config)
(require 'packages-config)

(when cfg/enable-email
  (require 'email-config))

(with-eval-after-load 'org
  (require 'org-pretty-table)
  (setq org-pretty-table-charset cfg/org-pretty-table-charset)
  (add-hook 'org-mode-hook #'org-pretty-table-mode))

(provide 'init)
;;; init.el ends here
