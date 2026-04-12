;;; plug-evilmode.el --- Evil configuration -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(use-package evil
  :init
  ;; These settings must be in place before Evil loads.  In particular,
  ;; `evil-want-C-u-scroll' is the switch that makes `C-u' behave like Vim's
  ;; half-page-up instead of falling through to Emacs prefix-argument behavior.
  (setq evil-want-C-i-jump nil
        evil-want-C-u-scroll t
        evil-want-C-u-delete t
        evil-want-keybinding nil
        evil-toggle-key ""
        evil-undo-system 'undo-tree
        evil-respect-visual-line-mode t)
  (evil-mode 1)
  :config
  (defun cfg/evil-escape-and-clear-search ()
    "Return to normal state and clear active Evil search highlighting.

This mirrors the user's Neovim setup, where pressing `Esc' in normal editing
contexts is expected to clear stale search highlighting instead of leaving
visual residue from a previous search session."
    (interactive)
    (when (fboundp 'evil-ex-nohighlight)
      (evil-ex-nohighlight))
    (evil-force-normal-state)
    (recenter))

  (define-key evil-insert-state-map [escape] #'evil-normal-state)
  (define-key evil-normal-state-map [escape] #'cfg/evil-escape-and-clear-search)
  (define-key evil-normal-state-map (kbd "TAB") #'indent-for-tab-command)
  ;; Wrapped-line movement should follow the display line by default, matching
  ;; the practical Vim experience the user has configured in Neovim.
  (define-key evil-normal-state-map [remap evil-next-line] #'evil-next-visual-line)
  (define-key evil-normal-state-map [remap evil-previous-line] #'evil-previous-visual-line)
  (define-key evil-motion-state-map [remap evil-next-line] #'evil-next-visual-line)
  (define-key evil-motion-state-map [remap evil-previous-line] #'evil-previous-visual-line)
  (define-key evil-visual-state-map [remap evil-next-line] #'evil-next-visual-line)
  (define-key evil-visual-state-map [remap evil-previous-line] #'evil-previous-visual-line)
  ;; Be explicit about half-page scrolling in both normal and motion states so
  ;; the mapping remains stable even if upstream defaults shift.
  (define-key evil-normal-state-map (kbd "C-d") #'evil-scroll-down)
  (define-key evil-normal-state-map (kbd "C-u") #'evil-scroll-up)
  (define-key evil-motion-state-map (kbd "C-d") #'evil-scroll-down)
  (define-key evil-motion-state-map (kbd "C-u") #'evil-scroll-up)
  ;; Match the user's Neovim and LazyVim expectation that Ctrl-h/j/k/l move
  ;; between windows instead of acting like unrelated Emacs control bindings in
  ;; normal state.
  (define-key evil-normal-state-map (kbd "C-h") #'evil-window-left)
  (define-key evil-normal-state-map (kbd "C-j") #'evil-window-down)
  (define-key evil-normal-state-map (kbd "C-k") #'evil-window-up)
  (define-key evil-normal-state-map (kbd "C-l") #'evil-window-right)
  ;; Preserve the operator/visual linewise motion customizations from
  ;; `nvim.mini`, where H and L are used as start/end-of-line helpers.
  (define-key evil-visual-state-map (kbd "H") #'evil-first-non-blank)
  (define-key evil-visual-state-map (kbd "L") #'evil-end-of-line)
  (define-key evil-operator-state-map (kbd "H") #'evil-first-non-blank)
  (define-key evil-operator-state-map (kbd "L") #'evil-end-of-line)
  ;; Keep search result traversal consistent with LazyVim by opening folds after
  ;; jumping to the next or previous match.
  (define-key evil-normal-state-map (kbd "n")
              (lambda ()
                (interactive)
                (evil-search-next)
                (evil-open-folds)))
  (define-key evil-normal-state-map (kbd "N")
              (lambda ()
                (interactive)
                (evil-search-previous)
                (evil-open-folds)))
  ;; Neovim-style quickfix navigation maps cleanly onto Emacs' next-error API,
  ;; which already drives compilation, grep, xref, and Flymake result lists.
  (define-key evil-normal-state-map (kbd "[q") #'previous-error)
  (define-key evil-normal-state-map (kbd "]q") #'next-error)
  (define-key evil-normal-state-map (kbd "W") (kbd "5w"))
  (define-key evil-normal-state-map (kbd "B") (kbd "5b"))
  (define-key evil-normal-state-map (kbd "C-s") #'save-buffer)
  ;; `Q' should be a narrow "leave this view" action, not "terminate Emacs".
  ;; `quit-window' is the closest safe analogue to the user's Neovim `:q`
  ;; muscle memory.
  (define-key evil-normal-state-map (kbd "Q") #'quit-window))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(provide 'plug-evilmode)
;;; plug-evilmode.el ends here
