;;; themes-config.el --- Theme and modeline configuration -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun cfg/apply-theme (&optional _frame)
  "Apply `cfg/default-theme' consistently to the current frame.

This helper centralizes theme activation so startup, later frame creation, and
manual reloads all follow the same path. Existing enabled themes are disabled
first to avoid layered face state from previous sessions or experiments."
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme cfg/default-theme t)
  (setq frame-background-mode 'dark)
  (when (display-graphic-p)
    (set-frame-parameter nil 'background-mode 'dark)))

(use-package modus-themes
  :ensure nil
  :init
  (setq modus-themes-italic-constructs t
        modus-themes-bold-constructs t
        modus-themes-mixed-fonts nil
        modus-themes-prompts '(bold intense)
        modus-themes-org-blocks 'gray-background)
  :config
  (cfg/apply-theme)
  (add-hook 'after-make-frame-functions #'cfg/apply-theme))

(provide 'themes-config)
;;; themes-config.el ends here
