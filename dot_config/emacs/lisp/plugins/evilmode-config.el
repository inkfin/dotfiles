(use-package evil
  :ensure t
  :init (evil-mode)
  :config
  (evil-set-undo-system 'undo-tree))

; evil-mode: insert mode is Emacs mode
(setq evil-toggle-key "")    ; remove default evil-toggle-key C-z, manually setup
(setq evil-want-C-i-jump nil)   ; don't bind [tab] to evil-jump-forward
; remove all keybindings from insert-state keymap, use emacs-state when editing
(setcdr evil-insert-state-map nil)
; ESC to switch back normal-state
(define-key evil-insert-state-map [escape] 'evil-normal-state)
; TAB to indent in normal-state
(define-key evil-normal-state-map (kbd "TAB") 'indent-for-tab-command)

; Use j/k to move one visual line insted of gj/gk
(define-key evil-normal-state-map (kbd "<remap> <evil-next-line>") 'evil-next-visual-line)
(define-key evil-normal-state-map (kbd "<remap> <evil-previous-line>") 'evil-previous-visual-line)
; Use W/K to accelerate word-element navigating
(define-key evil-normal-state-map (kbd "W") (kbd "5 w"))
(define-key evil-normal-state-map (kbd "B") (kbd "5 b"))

(define-key evil-normal-state-map (kbd "C-s") 'save-buffer)
(define-key evil-normal-state-map (kbd "Q") 'evil-save-and-close)

