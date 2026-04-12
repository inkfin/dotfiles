;;; local.el --- Machine-local toggles and overrides -*- lexical-binding: t; -*-
;;; Commentary:
;;
;; This file is meant to be created and managed locally, for example through a
;; chezmoi template or per-machine source file.  The shared config loads it
;; after `config.el', so any settings placed here override the tracked defaults.
;;
;; Keep this file focused on machine-local decisions:
;;
;; - which language groups are enabled on this machine
;; - whether optional integrations such as EAF are exposed
;; - local file paths or host-specific font tweaks
;;
;; The default state is intentionally minimal.  Nothing language-specific is
;; enabled until you opt in, which avoids package installs and missing-tool
;; errors on a fresh Windows machine.
;;
;;; Code:

;; Example:
;; (setq cfg/enabled-languages '(python web json yaml))

(setq cfg/enabled-languages '())

;; Optional feature toggles.
(setq cfg/enable-eaf nil)
;; (setq cfg/enable-dashboard nil)
;; (setq cfg/windows-font "Sarasa Term SC Nerd Font-16:weight=medium")

(provide 'local)
;;; local.el ends here
