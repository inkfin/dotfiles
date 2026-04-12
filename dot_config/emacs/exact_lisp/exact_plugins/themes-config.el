;;; themes-config.el --- Theme and modeline configuration -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package modus-themes
  :ensure nil
  :init
  (setq modus-themes-italic-constructs t
        modus-themes-bold-constructs t
        modus-themes-mixed-fonts nil
        modus-themes-prompts '(bold intense)
        modus-themes-org-blocks 'gray-background)
  :config
  (load-theme cfg/default-theme t))

(provide 'themes-config)
;;; themes-config.el ends here
