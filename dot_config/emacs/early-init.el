;;; early-init.el --- Boot-time startup optimizations -*- lexical-binding: t; -*-
;;; Commentary:
;;
;; Emacs loads `early-init.el' before package activation and before the normal
;; init file.  This is the correct place for low-level startup tuning that would
;; otherwise be partially too late in `init.el'.
;;
;; The guiding principle here is narrow scope:
;;
;; - only settings that materially affect startup should live here
;; - anything user-facing or mode-specific belongs in `init.el' or a module
;; - anything machine-local belongs in `local.el'
;;
;;; Code:

;; Do not let package.el activate packages before we can configure it.
(setq package-enable-at-startup nil)

;; Reduce startup work.  These values are intentionally aggressive only during
;; initialization and are restored in `after-init-hook'.
(defvar cfg/default-file-name-handler-alist file-name-handler-alist)
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6
      file-name-handler-alist nil
      read-process-output-max (* 1024 1024)
      process-adaptive-read-buffering nil
      bidi-inhibit-bpa t
      inhibit-compacting-font-caches t
      auto-mode-case-fold nil)

;; Skip GUI chrome as early as possible so the first frame starts closer to its
;; steady-state appearance.
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

;; Windows-specific startup reductions.  These are chosen because they reduce
;; expensive filesystem metadata and process I/O overhead without changing the
;; user's editing semantics.
(when (memq system-type '(ms-dos windows-nt cygwin))
  (setq w32-get-true-file-attributes nil
        w32-pipe-read-delay 0
        w32-pipe-buffer-size (* 64 1024)))

(add-hook
 'emacs-startup-hook
 (lambda ()
   (setq gc-cons-threshold (* 64 1024 1024)
         gc-cons-percentage 0.1
         file-name-handler-alist cfg/default-file-name-handler-alist)
   (garbage-collect)))

(provide 'early-init)
;;; early-init.el ends here
