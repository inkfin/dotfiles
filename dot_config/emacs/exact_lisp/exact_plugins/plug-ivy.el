;;; plug-ivy.el --- Modern completion UI -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun cfg/vertico-directory-up-or-delete-char ()
  "Move up one directory in file prompts, otherwise delete backward.

This follows the common Vertico file-prompt convention used by DoomEmacs while
remaining safe in non-file minibuffers. The result is that `C-h` feels useful
instead of becoming a mode-specific dead key."
  (interactive)
  (if (eq 'file (vertico--metadata-get 'category))
      (vertico-directory-up)
    (backward-delete-char-untabify 1)))

(defun cfg/vertico-enter-or-exit ()
  "Enter the current directory candidate or exit the minibuffer.

For file prompts this behaves like a directory-aware confirm key, which is much
closer to the user's Neovim picker muscle memory than plain Emacs completion
acceptance."
  (interactive)
  (if (eq 'file (vertico--metadata-get 'category))
      (vertico-directory-enter)
    (vertico-exit)))

(defun cfg/embark-consult-preview-at-point-mode-maybe ()
  "Enable preview-at-point in Embark collect buffers when available.

Consult has changed this preview surface across releases. This wrapper keeps
the hook soft-failing instead of assuming a specific Consult version forever."
  (when (fboundp 'consult-preview-at-point-mode)
    (consult-preview-at-point-mode 1)))

(use-package vertico
  :init
  (vertico-mode 1)
  :custom
  (vertico-count 14)
  (vertico-resize t)
  (vertico-cycle t)
  :bind
  (:map vertico-map
        ("C-j" . vertico-next)
        ("C-k" . vertico-previous)
        ("C-h" . cfg/vertico-directory-up-or-delete-char)
        ("C-l" . cfg/vertico-enter-or-exit)))

(use-package vertico-directory
  :ensure nil
  :after vertico
  :bind
  (:map vertico-map
        ("RET" . vertico-directory-enter)
        ("DEL" . vertico-directory-delete-char)
        ("M-DEL" . vertico-directory-delete-word)))

(use-package savehist
  :ensure nil
  :init
  (savehist-mode 1))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides
   '((file (styles basic partial-completion)))))

(use-package marginalia
  :after vertico
  :init
  (marginalia-mode 1))

(use-package consult
  :custom
  (consult-preview-key "C-SPC")
  :bind
  (("C-s" . consult-line)
   ("C-c s" . consult-ripgrep)
   ("M-y" . consult-yank-pop)
   ("C-x b" . consult-buffer)
   ("C-x C-r" . consult-recent-file)
   ("C-x C-@" . consult-mark)
   ("C-x C-SPC" . consult-mark)
   ("M-g g" . consult-goto-line)
   ("M-g i" . consult-imenu)
   ("M-g o" . consult-outline)
   ("<f1> f" . describe-function)
   ("<f1> v" . describe-variable)
   ("<f1> i" . info-lookup-symbol)))

(use-package embark
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim)
   ("C-c C-l" . embark-collect)
   ("C-c C-e" . embark-export)
   ("C-h B" . embark-bindings)))

(use-package embark-consult
  :after (embark consult)
  :hook
  (embark-collect-mode . cfg/embark-consult-preview-at-point-mode-maybe))

(with-eval-after-load 'embark
  ;; Embark collect buffers are effectively candidate lists. They are much more
  ;; comfortable in normal state, where `j`, `k`, `q`, and `RET` line up with
  ;; the user's Vim expectations.
  (when (featurep 'evil)
    (evil-set-initial-state 'embark-collect-mode 'normal)
    (evil-define-key 'normal embark-collect-mode-map
      (kbd "j") #'next-line
      (kbd "k") #'previous-line
      (kbd "q") #'quit-window
      (kbd "RET") #'embark-act)))

(provide 'plug-ivy)
;;; plug-ivy.el ends here
