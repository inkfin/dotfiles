;;; plug-dashboard.el --- Lightweight startup screen -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package dashboard
  :if (and cfg/enable-dashboard (display-graphic-p))
  :hook (after-init . dashboard-setup-startup-hook)
  :custom
  (dashboard-startup-banner 'official)
  (dashboard-banner-logo-title "Fast Emacs, low ceremony")
  (dashboard-center-content t)
  (dashboard-items '((recents . 8)
                     (projects . 5))))

(provide 'plug-dashboard)
;;; plug-dashboard.el ends here
