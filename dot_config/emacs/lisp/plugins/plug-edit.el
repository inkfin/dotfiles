;; which-key
(use-package which-key
  :ensure t
  :init (which-key-mode))

;; undo-tree
(use-package undo-tree
  :ensure t
  :diminish
  :init
  (global-undo-tree-mode)
  (setq undo-tree-auto-save-history nil)
)

;; rainbow-delimiters
(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

;; c-a, c-e enhanced
(use-package mwim
  :ensure t
  :bind
  ("C-a" . mwim-beginning-of-code-or-line)
  ("C-e" . mwim-end-of-code-or-line))

; remember recent M-x
(use-package amx
  :ensure t
  :init (amx-mode))

;; window switcher
(use-package ace-window
  :ensure t
  :bind (("C-x o" . 'ace-window)))

;;; GUI company-box
;(use-package company-box
;  :ensure t
;  :if window-system
;  :hook (company-mode . company-box-mode))

;; smooth scrooling
(use-package good-scroll
  :ensure t
  :if window-system          ; 在图形化界面时才使用这个插件
  :init (good-scroll-mode))

