;;; cfg-maintenance.el --- Package audit and pruning helpers -*- lexical-binding: t; -*-
;;; Commentary:
;;
;; This file gives the configuration a repeatable maintenance workflow instead
;; of relying on ad-hoc manual cleanup in the package directory.
;;
;; The central idea is simple:
;;
;; 1. define the package set the config intentionally manages
;; 2. expand that set to include installed dependencies
;; 3. compare the result with `package-alist'
;; 4. surface the difference as audit information or prune candidates
;;
;; This deliberately operates on the package graph that Emacs already knows
;; about.  It does not try to infer intent by scanning `elpa/' directly.
;;
;; The resulting commands are:
;;
;; - `cfg/package-audit-report'
;;   Show a buffer summarizing managed packages, dependency closure, installed
;;   packages, and orphaned packages.
;;
;; - `cfg/package-prune-orphans'
;;   Remove orphaned packages in dependency-safe order after confirmation.
;;
;; These commands are conservative by design.  A package is considered orphaned
;; only when it is not part of the dependency closure of the config-managed
;; package set.
;;
;;; Code:

(require 'package)
(require 'seq)
(require 'subr-x)

(defconst cfg/base-package-selection
  '(ace-window
    cape
    consult
    corfu
    dashboard
    embark
    embark-consult
    evil
    evil-collection
    magit
    marginalia
    mwim
    orderless
    rainbow-delimiters
    undo-tree
    vertico
    which-key
    yasnippet
    yasnippet-snippets)
  "Top-level packages intentionally managed by the shared config.

This list describes the editor packages that should exist regardless of which
language groups are enabled locally.")

(defconst cfg/language-package-map
  '((go . (go-mode))
    (rust . (rust-mode))
    (yaml . (yaml-mode)))
  "Mapping from language group symbols to extra top-level package names.

Only language groups that require third-party major modes appear here.  Built-in
language modes such as Python, JavaScript, JSON, shell, or C/C++ rely on Emacs
itself and therefore do not add package requirements.")

(defun cfg/managed-top-level-packages ()
  "Return the list of top-level packages intentionally managed by the config."
  (delete-dups
   (append
    cfg/base-package-selection
    (apply
     #'append
     (mapcar (lambda (language)
               (alist-get language cfg/language-package-map))
             cfg/enabled-languages)))))

(defun cfg/installed-package-descs ()
  "Return all installed package descriptors from `package-alist'."
  (mapcar #'cadr package-alist))

(defun cfg/installed-package-names ()
  "Return the names of all installed external packages."
  (sort (mapcar #'package-desc-name (cfg/installed-package-descs))
        (lambda (a b)
          (string-lessp (symbol-name a) (symbol-name b)))))

(defun cfg/package-installed-desc (name)
  "Return the installed package descriptor for NAME, or nil."
  (cadr (assq name package-alist)))

(defun cfg/package-dependencies (name)
  "Return installed dependency package names for package NAME."
  (when-let ((desc (cfg/package-installed-desc name)))
    (seq-filter
     #'identity
     (mapcar (lambda (req)
               (let ((dep-name (car req)))
                 (when (cfg/package-installed-desc dep-name)
                   dep-name)))
             (package-desc-reqs desc)))))

(defun cfg/package-closure (roots)
  "Return the installed dependency closure reachable from ROOTS."
  (let ((pending (copy-sequence roots))
        (seen '()))
    (while pending
      (let ((pkg (pop pending)))
        (when (and pkg
                   (cfg/package-installed-desc pkg)
                   (not (memq pkg seen)))
          (push pkg seen)
          (setq pending (append (cfg/package-dependencies pkg) pending)))))
    (sort seen (lambda (a b)
                 (string-lessp (symbol-name a) (symbol-name b))))))

(defun cfg/orphaned-packages ()
  "Return installed packages not required by the config-managed closure."
  (let* ((managed (cfg/managed-top-level-packages))
         (closure (cfg/package-closure managed))
         (installed (cfg/installed-package-names)))
    (seq-remove (lambda (pkg) (memq pkg closure)) installed)))

(defun cfg/package-dependents-in-set (target package-set)
  "Return packages in PACKAGE-SET that depend on TARGET."
  (seq-filter
   (lambda (pkg)
     (memq target (cfg/package-dependencies pkg)))
   package-set))

(defun cfg/orphan-prune-order ()
  "Return orphaned packages in dependency-safe deletion order.

The result prefers leaf packages first so `package-delete' does not fail due to
reverse dependencies among packages that are themselves being pruned."
  (let ((remaining (copy-sequence (cfg/orphaned-packages)))
        (result '()))
    (while remaining
      (let ((leaves
             (seq-filter
              (lambda (pkg)
                (null (cfg/package-dependents-in-set pkg remaining)))
              remaining)))
        (unless leaves
          ;; Fallback for unusual metadata cycles.  We still make progress rather
          ;; than erroring, but the command remains interactive and confirmed.
          (setq leaves (list (car remaining))))
        (dolist (pkg leaves)
          (push pkg result))
        (setq remaining (seq-remove (lambda (pkg) (memq pkg leaves)) remaining))))
    result))

(defun cfg/update-package-selected-packages ()
  "Synchronize `package-selected-packages' with the config-managed top-level set.

This keeps the Custom metadata aligned with the actual configuration instead of
preserving selections from an old stack forever."
  (interactive)
  (setq package-selected-packages (cfg/managed-top-level-packages))
  (when (called-interactively-p 'interactive)
    (customize-save-variable 'package-selected-packages package-selected-packages)
    (message "package-selected-packages updated to %s"
             package-selected-packages)))

(defun cfg/package-audit-report ()
  "Display a package audit report for the current configuration."
  (interactive)
  (let* ((managed (cfg/managed-top-level-packages))
         (closure (cfg/package-closure managed))
         (installed (cfg/installed-package-names))
         (orphans (cfg/orphaned-packages)))
    (with-current-buffer (get-buffer-create "*cfg Package Audit*")
      (setq buffer-read-only nil)
      (erase-buffer)
      (insert "cfg package audit\n\n")
      (insert "Config-managed top-level packages:\n")
      (dolist (pkg managed)
        (insert (format "- %s\n" pkg)))
      (insert "\nInstalled dependency closure:\n")
      (dolist (pkg closure)
        (insert (format "- %s\n" pkg)))
      (insert "\nInstalled packages on disk:\n")
      (dolist (pkg installed)
        (insert (format "- %s\n" pkg)))
      (insert "\nOrphaned packages:\n")
      (if orphans
          (dolist (pkg orphans)
            (insert (format "- %s\n" pkg)))
        (insert "- none\n"))
      (goto-char (point-min))
      (view-mode 1)
      (display-buffer (current-buffer)))))

(defun cfg/package-prune-orphans ()
  "Delete orphaned packages after interactive confirmation."
  (interactive)
  (let ((orphans (cfg/orphan-prune-order)))
    (if (null orphans)
        (message "No orphaned packages to prune.")
      (when (yes-or-no-p
             (format "Prune %d orphaned packages? %s "
                     (length orphans)
                     (mapconcat #'symbol-name orphans ", ")))
        (dolist (pkg orphans)
          (when-let ((desc (cfg/package-installed-desc pkg)))
            (package-delete desc nil)))
        (message "Pruned orphaned packages: %s"
                 (mapconcat #'symbol-name orphans ", "))))))

(provide 'cfg-maintenance)
;;; cfg-maintenance.el ends here
