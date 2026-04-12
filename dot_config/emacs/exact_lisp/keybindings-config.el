;;; keybindings-config.el --- User custom keybindings -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(global-set-key (kbd "RET") #'newline-and-indent)

(global-set-key (kbd "M-w") #'kill-region)
(global-set-key (kbd "C-w") #'kill-ring-save)
(global-set-key (kbd "C-a") #'back-to-indentation)
(global-set-key (kbd "M-m") #'move-beginning-of-line)
(global-set-key (kbd "C-c '") #'comment-or-uncomment-region)

(defun cfg/next-five-lines ()
  "Move cursor forward by five lines."
  (interactive)
  (next-line 5))

(defun cfg/previous-five-lines ()
  "Move cursor backward by five lines."
  (interactive)
  (previous-line 5))

(global-set-key (kbd "M-n") #'cfg/next-five-lines)
(global-set-key (kbd "M-p") #'cfg/previous-five-lines)

(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

;; Package maintenance commands are kept under a narrow prefix so they are easy
;; to remember but do not collide with normal editing commands.
(global-set-key (kbd "C-c p a") #'cfg/package-audit-report)
(global-set-key (kbd "C-c p p") #'cfg/package-prune-orphans)
(global-set-key (kbd "C-c p s") #'cfg/update-package-selected-packages)

(defvar cfg/leader-map (make-sparse-keymap "cfg leader")
  "Top-level leader keymap for Vim-style global commands.

This map is intended to be bound to `SPC' in Evil normal, motion, and visual
states.  A matching global fallback is also installed on `C-c SPC' so the same
command tree remains reachable even when Evil is not active.")

(defvar cfg/leader-buffer-map (make-sparse-keymap "buffer")
  "Leader submap for buffer commands.")

(defvar cfg/leader-code-map (make-sparse-keymap "code")
  "Leader submap for code, LSP, and diagnostics commands.")

(defvar cfg/leader-file-map (make-sparse-keymap "file")
  "Leader submap for file commands.")

(defvar cfg/leader-git-map (make-sparse-keymap "git")
  "Leader submap for Git and Magit commands.")

(defvar cfg/leader-open-map (make-sparse-keymap "open")
  "Leader submap for organizer and open-style commands.")

(defvar cfg/leader-package-map (make-sparse-keymap "package")
  "Leader submap for package maintenance commands.")

(defvar cfg/leader-search-map (make-sparse-keymap "search")
  "Leader submap for search and navigation commands.")

(defvar cfg/leader-window-map (make-sparse-keymap "window")
  "Leader submap for window management commands.")

(defvar cfg/org-localleader-map (make-sparse-keymap "org")
  "Mode-local leader map for Org buffers.")

(defvar cfg/magit-localleader-map (make-sparse-keymap "magit")
  "Mode-local leader map for Magit buffers.")

(defvar cfg/eglot-localleader-map (make-sparse-keymap "eglot")
  "Mode-local leader map for Eglot-managed buffers.")

(defun cfg/find-user-init-file ()
  "Open the main runtime entrypoint for this Emacs configuration."
  (interactive)
  (cfg/open-user-file "init.el"))

(defun cfg/find-config-file ()
  "Open the tracked shared config file."
  (interactive)
  (cfg/open-user-file "config.el"))

(defun cfg/find-local-file ()
  "Open the machine-local override file."
  (interactive)
  (cfg/open-user-file "local.el"))

(defun cfg/find-readme-file ()
  "Open the main configuration documentation."
  (interactive)
  (cfg/open-user-file "README.md"))

(defun cfg/find-agents-file ()
  "Open the repository-local agent/reference instructions."
  (interactive)
  (cfg/open-user-file "AGENTS.md"))

(defun cfg/find-early-init-file ()
  "Open the early startup configuration file."
  (interactive)
  (cfg/open-user-file "early-init.el"))

(defun cfg/bind-leader-keymap (key keymap)
  "Bind KEY to KEYMAP inside `cfg/leader-map'."
  (define-key cfg/leader-map (kbd key) keymap))

(cfg/define-keys
 cfg/leader-map
 '(("SPC" . execute-extended-command)))

(dolist (entry '(("b" . cfg/leader-buffer-map)
                 ("c" . cfg/leader-code-map)
                 ("f" . cfg/leader-file-map)
                 ("g" . cfg/leader-git-map)
                 ("o" . cfg/leader-open-map)
                 ("p" . cfg/leader-package-map)
                 ("s" . cfg/leader-search-map)
                 ("w" . cfg/leader-window-map)))
  (cfg/bind-leader-keymap (car entry) (symbol-value (cdr entry))))

(cfg/define-keys
 cfg/leader-buffer-map
 '(("b" . consult-buffer)
   ("d" . kill-current-buffer)
   ("n" . next-buffer)
   ("p" . previous-buffer)
   ("r" . revert-buffer)))

(cfg/define-keys
 cfg/leader-code-map
 '(("a" . eglot-code-actions)
   ("d" . flymake-show-buffer-diagnostics)
   ("f" . eglot-format-buffer)
   ("r" . eglot-rename)))

(cfg/define-keys
 cfg/leader-file-map
 '(("a" . cfg/find-agents-file)
   ("c" . cfg/find-config-file)
   ("e" . cfg/find-user-init-file)
   ("E" . cfg/find-early-init-file)
   ("f" . find-file)
   ("l" . cfg/find-local-file)
   ("r" . consult-recent-file)
   ("R" . cfg/find-readme-file)
   ("s" . save-buffer)))

(cfg/define-keys
 cfg/leader-git-map
 '(("f" . magit-file-dispatch)
   ("g" . magit-status)))

(cfg/define-keys
 cfg/leader-open-map
 '(("a" . org-agenda)
   ("c" . org-capture)
   ("l" . org-store-link)))

(cfg/define-keys
 cfg/leader-package-map
 '(("a" . cfg/package-audit-report)
   ("p" . cfg/package-prune-orphans)
   ("s" . cfg/update-package-selected-packages)))

(cfg/define-keys
 cfg/leader-search-map
 '(("b" . consult-line)
   ("g" . consult-ripgrep)
   ("i" . consult-imenu)))

(cfg/define-keys
 cfg/leader-window-map
 '(("d" . delete-window)
   ("h" . evil-window-left)
   ("j" . evil-window-down)
   ("k" . evil-window-up)
   ("l" . evil-window-right)
   ("o" . ace-window)
   ("s" . split-window-below)
   ("v" . split-window-right)))

;; Non-Evil fallback. This keeps the leader tree usable during startup,
;; troubleshooting, or in any session where Evil is intentionally disabled.
(global-set-key (kbd "C-c SPC") cfg/leader-map)

(with-eval-after-load 'evil
  ;; Bind the leader key in the Vim-facing states where fast mnemonic access is
  ;; most useful. Motion state is included so the leader remains available in
  ;; read-only/special views that Evil places in motion state.
  (evil-global-set-key 'normal (kbd "SPC") cfg/leader-map)
  (evil-global-set-key 'motion (kbd "SPC") cfg/leader-map)
  (evil-global-set-key 'visual (kbd "SPC") cfg/leader-map))

(with-eval-after-load 'which-key
  ;; Feed which-key meaningful group names so the leader tree reads like a real
  ;; command palette instead of an arbitrary pile of prefixes.
  (cfg/which-key-labels cfg/leader-map
                        '("b" "buffer" "c" "code" "f" "file" "g" "git"
                          "m" "mode" "o" "open" "p" "package" "s" "search"
                          "w" "window"))
  (cfg/which-key-labels cfg/leader-buffer-map
                        '("b" "switch buffer" "d" "delete buffer"
                          "n" "next buffer" "p" "previous buffer"
                          "r" "revert buffer"))
  (cfg/which-key-labels cfg/leader-code-map
                        '("a" "code action" "d" "diagnostics list"
                          "f" "format buffer" "r" "rename symbol"))
  (cfg/which-key-labels cfg/leader-file-map
                        '("a" "open AGENTS.md" "c" "open config.el"
                          "e" "open init.el" "E" "open early-init.el"
                          "f" "find file" "l" "open local.el"
                          "r" "recent files" "R" "open README.md"
                          "s" "save file"))
  (cfg/which-key-labels cfg/leader-git-map
                        '("f" "magit file dispatch" "g" "magit status"))
  (cfg/which-key-labels cfg/leader-open-map
                        '("a" "agenda" "c" "capture" "l" "store link"))
  (cfg/which-key-labels cfg/leader-package-map
                        '("a" "audit packages" "p" "prune orphans"
                          "s" "sync selected packages"))
  (cfg/which-key-labels cfg/leader-search-map
                        '("b" "search buffer" "g" "ripgrep" "i" "imenu"))
  (cfg/which-key-labels cfg/leader-window-map
                        '("d" "delete window" "h" "window left"
                          "j" "window down" "k" "window up"
                          "l" "window right" "o" "ace window"
                          "s" "split below" "v" "split right")))

(with-eval-after-load 'org
  ;; Org is the clearest case for a localleader: its actions are rich,
  ;; buffer-local, and would be clutter at the global leader level.
  (cfg/define-keys
   cfg/org-localleader-map
   '(("a" . org-archive-subtree-default)
     ("d" . org-deadline)
     ("l" . org-insert-link)
     ("s" . org-schedule)
     ("t" . org-todo)))

  (when (featurep 'evil)
    (evil-define-key '(normal visual motion) org-mode-map
      (kbd ",") cfg/org-localleader-map
      (kbd "SPC m") cfg/org-localleader-map))

  (with-eval-after-load 'which-key
    (cfg/which-key-labels cfg/org-localleader-map
                          '("a" "archive subtree" "d" "deadline"
                            "l" "insert link" "s" "schedule" "t" "todo"))))

(with-eval-after-load 'magit
  ;; Keep Magit's highest-value actions close to the fingers in status and diff
  ;; views while still leaving Magit's own single-key UI intact.
  (cfg/define-keys
   cfg/magit-localleader-map
   '(("b" . magit-branch-checkout)
     ("c" . magit-commit-create)
     ("f" . magit-fetch)
     ("g" . magit-refresh)
     ("p" . magit-push-current-to-pushremote)
     ("s" . magit-stage)
     ("u" . magit-unstage)))

  (when (featurep 'evil)
    (evil-define-key '(normal visual motion) magit-mode-map
      (kbd ",") cfg/magit-localleader-map
      (kbd "SPC m") cfg/magit-localleader-map))

  (with-eval-after-load 'which-key
    (cfg/which-key-labels cfg/magit-localleader-map
                          '("b" "checkout branch" "c" "commit create"
                            "f" "fetch" "g" "refresh" "p" "push"
                            "s" "stage" "u" "unstage"))))

(with-eval-after-load 'eglot
  ;; Eglot-managed buffers already have direct Vim motions such as `gd` and
  ;; `[d`. The localleader groups the less mnemonic code actions.
  (cfg/define-keys
   cfg/eglot-localleader-map
   '(("a" . eglot-code-actions)
     ("d" . flymake-show-buffer-diagnostics)
     ("f" . eglot-format-buffer)
     ("h" . eldoc)
     ("r" . eglot-rename)))

  (when (featurep 'evil)
    (evil-define-key '(normal visual motion) eglot-mode-map
      (kbd ",") cfg/eglot-localleader-map
      (kbd "SPC m") cfg/eglot-localleader-map))

  (with-eval-after-load 'which-key
    (cfg/which-key-labels cfg/eglot-localleader-map
                          '("a" "code action" "d" "diagnostics list"
                            "f" "format buffer" "h" "hover / eldoc"
                            "r" "rename symbol"))))

(provide 'keybindings-config)
;;; keybindings-config.el ends here
