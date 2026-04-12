;;; plug-dashboard.el --- Lightweight startup screen -*- lexical-binding: t; -*-
;;; Commentary:
;;
;; Keep the dashboard simple. The package already provides a decent startup
;; screen; the main gaps for this config are startup aesthetics and keyboard
;; ergonomics. Keep the package-native layout, but restore the ASCII banner and
;; add a small navigator row plus direct single-key actions so the welcome
;; screen behaves more like a Neovim dashboard landing page.
;;
;;; Code:

(defconst cfg/dashboard-banner
  (concat
   " ███████╗███╗   ███╗ █████╗  ██████╗███████╗\n"
   " ██╔════╝████╗ ████║██╔══██╗██╔════╝██╔════╝\n"
   " █████╗  ██╔████╔██║███████║██║     ███████╗\n"
   " ██╔══╝  ██║╚██╔╝██║██╔══██║██║     ╚════██║\n"
   " ███████╗██║ ╚═╝ ██║██║  ██║╚██████╗███████║\n"
   " ╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝╚══════╝")
  "ASCII banner used by the startup dashboard.")

(defun cfg/dashboard-open-scratch ()
  "Switch to the scratch buffer from the dashboard."
  (interactive)
  (switch-to-buffer (get-buffer-create "*scratch*"))
  (lisp-interaction-mode))

(defun cfg/dashboard-open-project ()
  "Open the built-in project switcher from the dashboard."
  (interactive)
  (call-interactively #'project-switch-project))

(defun cfg/dashboard-insert-action-buttons ()
  "Insert a simple centered row of dashboard action buttons.

This intentionally avoids the package's navigator widget format, which is
surprisingly brittle. Plain text buttons are enough here and keep the startup
screen predictable."
  (let ((buttons '(("Find file" . find-file)
                   ("Recent files" . consult-recent-file)
                   ("Projects" . cfg/dashboard-open-project)
                   ("Magit" . magit-status)
                   ("Config" . cfg/find-user-init-file)
                   ("Scratch" . cfg/dashboard-open-scratch)))
        (start (point)))
    (dolist (button buttons)
      (insert-text-button
       (format "[%s]" (car button))
       'action (lambda (_button) (call-interactively (cdr button)))
       'follow-link t
       'help-echo (format "Run %s" (cdr button))
       'face 'dashboard-navigator)
      (insert " "))
    (delete-char -1)
    (insert "\n")
    (when (fboundp 'dashboard-center-text)
      (dashboard-center-text start (1- (point))))))

(defun cfg/dashboard-setup-keys ()
  "Add direct single-key actions to the dashboard buffer."
  (define-key dashboard-mode-map (kbd "f") #'find-file)
  (define-key dashboard-mode-map (kbd "r") #'consult-recent-file)
  (define-key dashboard-mode-map (kbd "p") #'cfg/dashboard-open-project)
  (define-key dashboard-mode-map (kbd "g") #'magit-status)
  (define-key dashboard-mode-map (kbd "c") #'cfg/find-user-init-file)
  (define-key dashboard-mode-map (kbd "s") #'cfg/dashboard-open-scratch)
  (define-key dashboard-mode-map (kbd "q") #'quit-window))

(use-package dashboard
  :if (and cfg/enable-dashboard (display-graphic-p))
  :hook ((after-init . dashboard-setup-startup-hook)
         (dashboard-mode . cfg/dashboard-setup-keys))
  :custom
  (dashboard-startup-banner 'ascii)
  (dashboard-banner-ascii cfg/dashboard-banner)
  (dashboard-banner-logo-title "Fast Emacs, low ceremony")
  (dashboard-center-content t)
  (dashboard-show-shortcuts nil)
  (dashboard-startupify-list
   '(dashboard-insert-banner
     dashboard-insert-banner-title
     dashboard-insert-newline
     cfg/dashboard-insert-action-buttons
     dashboard-insert-newline
     dashboard-insert-items
     dashboard-insert-newline
     dashboard-insert-footer))
  (dashboard-show-shortcuts nil)
  (dashboard-items '((recents . 8)
                     (projects . 5))))

(provide 'plug-dashboard)
;;; plug-dashboard.el ends here
