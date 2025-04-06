;;; packages-config.el -- custom pakages imports
;;; Commentary:
;;; Code:

;; setup package and use-package

;; 腾讯源
(require 'package)
(setq package-archives '(("gnu"    . "https://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("nongnu" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
                         ("melpa"  . "https://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))
(package-initialize)

;; Booststrap 'use-package
; (eval-after-load 'gnutls
;     '(add-to-list 'gnutls-trustfiles "/etc/ssl/cert.pem"))
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

(eval-and-compile
  (setq use-package-always-ensure t)
  (setq use-package-always-defer t)
  (setq use-package-always-demand nil)
  (setq use-package-expand-minimally t)
  (setq use-package-verbose t))


;;; load all the plugins

(let ((plugin-dir (expand-file-name "lisp/plugins" user-emacs-directory)))
  (when (file-directory-p plugin-dir)
    (dolist (file (directory-files plugin-dir t "\\.el$"))
      (load file nil 'nomessage))))

(provide 'packages-config)

;;; packages-config.el ends here
