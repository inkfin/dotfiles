;;; plug-magit.el --- Git and Magit workflow -*- lexical-binding: t; -*-
;;; Commentary:
;;
;; Magit is one of the places where a nominally Evil-enabled Emacs setup can
;; still feel unexpectedly "Emacs-first". This module keeps the configuration
;; modest but intentional:
;;
;; - expose a standard global entrypoint on `C-x g`
;; - let `evil-collection` provide broad mode coverage
;; - add a few high-value Vim-like motions used constantly in status and diff
;;   buffers
;; - make quitting Magit buffers behave like leaving a view, not like burying
;;   the user in an unfamiliar special-mode interaction model
;;
;;; Code:

(use-package magit
  :commands (magit-status magit-file-dispatch)
  :bind
  (("C-x g" . magit-status))
  :custom
  (magit-diff-refine-hunk t)
  (magit-save-repository-buffers nil)
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  :config
  (setq magit-bury-buffer-function #'magit-mode-quit-window)

  (when (featurep 'evil)
    ;; These keys are the highest-frequency Magit interactions and benefit the
    ;; most from explicit Vim-style normalization.
    (evil-define-key '(normal visual) magit-mode-map
      (kbd "q") #'quit-window
      (kbd "Q") #'magit-mode-bury-buffer
      (kbd "gr") #'magit-refresh
      (kbd "gR") #'magit-refresh-all
      (kbd "zt") #'evil-scroll-line-to-top
      (kbd "zz") #'evil-scroll-line-to-center
      (kbd "zb") #'evil-scroll-line-to-bottom)
    (evil-define-key 'normal magit-diff-mode-map
      (kbd "gd") #'magit-jump-to-diffstat-or-diff)
    (evil-define-key 'normal magit-mode-map
      (kbd "]") #'magit-section-forward-sibling
      (kbd "[") #'magit-section-backward-sibling))

  ;; Avoid accidental escapes closing or perturbing transient Magit workflows.
  (define-key transient-map [escape] #'transient-quit-one))

(provide 'plug-magit)
;;; plug-magit.el ends here
