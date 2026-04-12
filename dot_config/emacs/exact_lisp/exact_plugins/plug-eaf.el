;;; plug-eaf.el --- Optional EAF integration -*- lexical-binding: t; -*-
;;; Commentary:
;;
;; EAF is intentionally not loaded at startup.  When the local checkout exists,
;; we only add it to `load-path` and provide a helper command that performs the
;; expensive module loading on demand.
;;
;;; Code:

(let ((eaf-dir (expand-file-name "site-lisp/emacs-application-framework"
                                 user-emacs-directory)))
  (when (and cfg/enable-eaf (file-directory-p eaf-dir))
    (add-to-list 'load-path eaf-dir)

    (defun cfg/load-eaf ()
      "Load Emacs Application Framework and its preferred modules."
      (interactive)
      (require 'eaf)
      (require 'eaf-browser)
      (require 'eaf-pdf-viewer)
      (require 'eaf-image-viewer)
      (require 'eaf-markdown-previewer)
      (require 'eaf-file-manager)
      (require 'eaf-video-player)
      (require 'eaf-org-previewer)
      (setq eaf-browser-continue-where-left-off t
            eaf-browser-enable-adblocker t
            browse-url-browser-function #'eaf-open-browser)
      (defalias 'browse-web #'eaf-open-browser)
      (eaf-bind-key scroll_up "C-n" eaf-pdf-viewer-keybinding)
      (eaf-bind-key scroll_down "C-p" eaf-pdf-viewer-keybinding)
      (eaf-bind-key nil "M-q" eaf-browser-keybinding))

    (global-set-key (kbd "C-c e") #'cfg/load-eaf)))

(provide 'plug-eaf)
;;; plug-eaf.el ends here
