(let ((eaf-dir (expand-file-name "site-lisp/emacs-application-framework" user-emacs-directory)))
  (when (file-directory-p eaf-dir)
    ;; add EAF to load-path
    (add-to-list 'load-path eaf-dir)
    (require 'eaf)

    ;; load EAF modules
    (require 'eaf-browser)
    (require 'eaf-pdf-viewer)
    (require 'eaf-music-player)
    (require 'eaf-rss-reader)
    (require 'eaf-image-viewer)
    (require 'eaf-markdown-previewer)
    (require 'eaf-file-manager)
    (require 'eaf-video-player)
    (require 'eaf-org-previewer)
    (require 'eaf-jupyter)
    (require 'eaf-git)
    (require 'eaf-system-monitor)

    ;; configure EAF
    ; See https://github.com/emacs-eaf/emacs-application-framework/wiki/Customization
    (setq eaf-browser-continue-where-left-off t
          eaf-browser-enable-adblocker t
          browse-url-browser-function 'eaf-open-browser)
    (defalias 'browse-web #'eaf-open-browser)

    ;; bind keys for EAF
    (eaf-bind-key scroll_up "C-n" eaf-pdf-viewer-keybinding)
    (eaf-bind-key scroll_down "C-p" eaf-pdf-viewer-keybinding)
    ;(eaf-bind-key take_photo "p" eaf-camera-keybinding)
    (eaf-bind-key nil "M-q" eaf-browser-keybinding) ;; unbind, see more in the Wiki
  )
)

