;;; email-config.el --- inkfin's email config*

;;; Commentary:
;; receive and send QQ mails
;;; Code:

(require 'auth-source)
(setq auth-sources '("~/.config/emacs/config/authinfo"))
;; (customize-variable 'auth-sources) ;; need to do it once

(setq message-send-mail-function 'smtpmail-send-it)
(setq user-full-name "inkfin")
(setq user-mail-address "inkfin@qq.com")
(setq smtpmail-smtp-user "inkfin@qq.com"
      smtpmail-smtp-server "smtp.qq.com"
      smtpmail-smtp-service 465
      smtpmail-stream-type 'ssl)

;; Debug
(setq smtpmail-debug-info t)
(setq smtpmail-debug-verb t)


(provide 'email-config)
;;; email-config.el ends here
