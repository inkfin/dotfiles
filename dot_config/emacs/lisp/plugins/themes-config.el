(use-package dracula-theme
  :ensure t
)
(load-theme 'dracula t)

;; mode line prettier
(use-package smart-mode-line
  :ensure t
  :init
  (setq sml/no-confirm-load-theme t)
  (sml/setup))
