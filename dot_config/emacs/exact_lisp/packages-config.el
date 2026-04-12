;;; packages-config.el --- Package bootstrap and module loading -*- lexical-binding: t; -*-
;;; Commentary:
;;
;; This file bootstraps package.el, configures use-package, and then requires
;; the feature modules that assemble the editor.
;;
;; A deliberate design goal here is to keep package policy centralized:
;;
;; - package archives and refresh policy live here
;; - `use-package' behavior lives here
;; - module ordering lives here
;;
;; Language-specific activation does not live here.  That belongs in the
;; language module so opt-in language behavior stays separate from package
;; bootstrap mechanics.
;;
;;; Code:

(require 'package)
(require 'seq)

(setq package-archives
      '(("gnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
        ("nongnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
        ("melpa" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/"))
      package-archive-priorities
      '(("gnu" . 30)
        ("nongnu" . 20)
        ("melpa" . 10))
      package-quickstart t
      package-install-upgrade-built-in t
      package-native-compile t)

(package-initialize)

(defun cfg/package-archive-file (archive-name)
  "Return the local archive metadata file path for ARCHIVE-NAME."
  (expand-file-name
   (format "elpa/archives/%s/archive-contents" archive-name)
   user-emacs-directory))

(defun cfg/package-archive-stale-p ()
  "Return non-nil when local package archive metadata should be refreshed."
  (let ((max-age (* 7 24 60 60))
        (now (float-time)))
    (seq-some
     (lambda (archive)
       (let ((archive-file (cfg/package-archive-file (car archive))))
         (or (not (file-exists-p archive-file))
             (> (- now (float-time (file-attribute-modification-time
                                    (file-attributes archive-file))))
                max-age))))
     package-archives)))

(when (or (null package-archive-contents)
          (cfg/package-archive-stale-p))
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)

(setq use-package-always-ensure t
      use-package-compute-statistics t
      use-package-expand-minimally t
      use-package-enable-imenu-support t
      use-package-always-defer t
      use-package-verbose nil)

(require 'themes-config)
(require 'plug-edit)
(require 'plug-evilmode)
(require 'plug-autocomplete)
(require 'plug-ivy)
(require 'plug-languages)
(require 'plug-magit)
(require 'plug-dashboard)
(require 'plug-eaf)

(provide 'packages-config)
;;; packages-config.el ends here
