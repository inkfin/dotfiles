;;; email-config.el --- Lazy mail defaults -*- lexical-binding: t; -*-
;;; Commentary:
;;
;; Mail settings are kept lazy so the editor does not touch SMTP or mail
;; composition infrastructure during startup.  Identity values come from
;; `config.el' or `local.el', which keeps this module free of tracked-vs-local
;; policy decisions.
;;
;;; Code:

(require 'auth-source)

(setq auth-sources cfg/auth-sources)

(with-eval-after-load 'message
  (setq user-full-name cfg/user-full-name
        user-mail-address cfg/user-mail-address
        message-send-mail-function #'smtpmail-send-it))

(with-eval-after-load 'smtpmail
  (setq smtpmail-smtp-user cfg/smtp-user
        smtpmail-smtp-server cfg/smtp-server
        smtpmail-smtp-service cfg/smtp-service
        smtpmail-stream-type cfg/smtp-stream-type
        smtpmail-debug-info nil
        smtpmail-debug-verb nil))

(provide 'email-config)
;;; email-config.el ends here
