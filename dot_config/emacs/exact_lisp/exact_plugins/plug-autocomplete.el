;;; plug-autocomplete.el --- Modern in-buffer completion -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(defun cfg/corfu-scroll-documentation-up ()
  "Scroll Corfu documentation upward when available.

This mirrors the user's Neovim completion setup, where `C-u' inside the
completion UI scrolls the documentation window first and only falls back to a
normal editing action when no documentation popup is available."
  (interactive)
  (if (and (boundp 'corfu-popupinfo-mode)
           corfu-popupinfo-mode
           (fboundp 'corfu-popupinfo-scroll-up)
           (fboundp 'corfu-popupinfo--visible-p)
           (corfu-popupinfo--visible-p))
      (corfu-popupinfo-scroll-up)
    (scroll-down-command)))

(defun cfg/corfu-scroll-documentation-down ()
  "Scroll Corfu documentation downward when available.

The fallback remains a normal page scroll so the key never becomes a dead or
surprising no-op when completion is active but documentation is not visible."
  (interactive)
  (if (and (boundp 'corfu-popupinfo-mode)
           corfu-popupinfo-mode
           (fboundp 'corfu-popupinfo-scroll-down)
           (fboundp 'corfu-popupinfo--visible-p)
           (corfu-popupinfo--visible-p))
      (corfu-popupinfo-scroll-down)
    (scroll-up-command)))

(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))

(use-package corfu
  :init
  (global-corfu-mode 1)
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.15)
  (corfu-auto-prefix 2)
  (corfu-cycle t)
  (corfu-preview-current nil)
  (corfu-preselect 'prompt)
  (corfu-popupinfo-delay '(0.4 . 0.2))
  :bind
  (:map corfu-map
        ("TAB" . corfu-next)
        ([tab] . corfu-next)
        ("S-TAB" . corfu-previous)
        ([backtab] . corfu-previous)
        ("C-h" . corfu-popupinfo-toggle)
        ("C-u" . cfg/corfu-scroll-documentation-up)
        ("C-d" . cfg/corfu-scroll-documentation-down)
        ("RET" . corfu-insert)))

(use-package corfu-popupinfo
  :after corfu
  :ensure nil
  :init
  (corfu-popupinfo-mode 1))

(use-package yasnippet
  :hook (prog-mode . yas-minor-mode)
  :config
  (yas-reload-all)
  :bind
  (:map yas-minor-mode-map
        ("S-<tab>" . yas-expand)))

(use-package yasnippet-snippets
  :after yasnippet)

(global-set-key (kbd "M-/") #'completion-at-point)

(provide 'plug-autocomplete)
;;; plug-autocomplete.el ends here
