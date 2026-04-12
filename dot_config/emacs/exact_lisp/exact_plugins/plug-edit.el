;;; plug-edit.el --- Editing experience helpers -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package which-key
  :defer 1
  :init
  (which-key-mode 1)
  :custom
  (which-key-idle-delay 0.5)
  (which-key-sort-order #'which-key-key-order-alpha))

(use-package undo-tree
  :init
  (global-undo-tree-mode 1)
  :custom
  (undo-tree-auto-save-history nil)
  (undo-limit (* 4 1024 1024))
  (undo-strong-limit (* 16 1024 1024))
  (undo-outer-limit (* 64 1024 1024)))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package mwim
  :bind
  (("C-a" . mwim-beginning-of-code-or-line)
   ("C-e" . mwim-end-of-code-or-line)))

(use-package ace-window
  :bind (("C-x o" . ace-window)))

(provide 'plug-edit)
;;; plug-edit.el ends here
