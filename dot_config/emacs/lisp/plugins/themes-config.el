(use-package evil
  :ensure t
  :config
  (load-theme 'dracula t))

;; mode line prettier
(use-package smart-mode-line
  :ensure t
  :init
  (setq sml/no-confirm-load-theme t)
  (sml/setup))
