;;; packages-config.el -- custom pakages imports
;;; Commentary:
;;; Code:

;; setup package and use-package

;; 腾讯源
(require 'package)
(setq package-archives '(("gnu"   . "http://mirrors.cloud.tencent.com/elpa/gnu/")
                         ("melpa" . "http://mirrors.cloud.tencent.com/elpa/melpa/")))
(package-initialize)

;; Booststrap 'use-package
(eval-after-load 'gnutls
    '(add-to-list 'gnutls-trustfiles "/etc/ssl/cert.pem"))
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

;; undo-tree
(use-package undo-tree
  :ensure t
  :init (global-undo-tree-mode))

;; == evil-mode ==
;(use-package evil
;  :ensure t
;  :init (evil-mode)
;  :config
;  (evil-set-undo-system 'undo-tree))

;; evil-mode: insert mode is Emacs mode
;(setq evil-toggle-key "")    ; remove default evil-toggle-key C-z, manually setup
;(setq evil-want-C-i-jump nil)   ; don't bind [tab] to evil-jump-forward
;; remove all keybindings from insert-state keymap, use emacs-state when editing
;(setcdr evil-insert-state-map nil)
;; ESC to switch back normal-state
;(define-key evil-insert-state-map [escape] 'evil-normal-state)
;; TAB to indent in normal-state
;(define-key evil-normal-state-map (kbd "TAB") 'indent-for-tab-command)

;; Use j/k to move one visual line insted of gj/gk
;(define-key evil-normal-state-map (kbd "<remap> <evil-next-line>") 'evil-next-visual-line)
;(define-key evil-normal-state-map (kbd "<remap> <evil-previous-line>") 'evil-previous-visual-line)
;; Use J/K to accelerate navigating
;(define-key evil-normal-state-map (kbd "J") (kbd "5 j"))
;(define-key evil-normal-state-map (kbd "K") (kbd "5 k"))
;; Use W/K to accelerate word-element navigating
;(define-key evil-normal-state-map (kbd "W") (kbd "5 w"))
;(define-key evil-normal-state-map (kbd "B") (kbd "5 b"))

;(define-key evil-normal-state-map (kbd "S") 'save-buffer)
;(define-key evil-normal-state-map (kbd "Q") 'evil-save-and-close)


;; which-key
(use-package which-key
  :ensure t
  :init (which-key-mode))

;; c-a, c-e enhanced
(use-package mwim
  :ensure t
  :bind
  ("C-a" . mwim-beginning-of-code-or-line)
  ("C-e" . mwim-end-of-code-or-line))

; remember recent M-x
(use-package amx
  :ensure t
  :init (amx-mode))


;; == counsel & ivy ==
;; fuzzy search provider
(use-package counsel
  :ensure t)

(use-package ivy
  :ensure t                          ; 确认安装，如果没有安装过 ivy 就自动安装
  :init                              ; 加载后启动 ivy-mode
  (ivy-mode 1)
  (counsel-mode 1)
  :config                            ; 在加载插件后执行一些命令
  (setq ivy-use-virtual-buffers t)   ; 一些官网提供的固定配置
  (setq search-default-mode #'char-fold-to-regexp)
  (setq ivy-count-format "(%d/%d) ")
  :bind                              ; 以下为绑定快捷键
  (("C-s" . 'swiper-isearch)         ; 绑定快捷键 C-s 为 swiper-search，替换原本的搜索功能
   ("M-x" . 'counsel-M-x)            ; 使用 counsel 替换命令输入，给予更多提示
   ("C-x C-f" . 'counsel-find-file)  ; 使用 counsel 做文件打开操作，给予更多提示
   ("M-y" . 'counsel-yank-pop)       ; 使用 counsel 做历史剪贴板粘贴，可以展示历史
   ("C-x C-@" . 'counsel-mark-ring)  ; 在某些终端上 C-x C-SPC 会被映射为 C-x C-@，比如在 macOS 上，所以要手动设置
   ("C-x C-SPC" . 'counsel-mark-ring)
   ("C-x b" . 'ivy-switch-buffer)    ; 使用 ivy 做 buffer 切换，给予更多提示
   ("C-c v" . 'ivy-push-view)        ; 记录当前 buffer 的信息
   ("C-c s" . 'ivy-switch-view)      ; 切换到记录过的 buffer 位置
   ("C-c V" . 'ivy-pop-view)         ; 移除 buffer 记录
   ("C-x C-SPC" . 'counsel-mark-ring) ; 使用 counsel 记录 mark 的位置
   ("<f1> f" . 'counsel-describe-function)
   ("<f1> v" . 'counsel-describe-variable)
   ("<f1> i" . 'counsel-info-lookup-symbol)
   ("C-S-j" . 'ivy-immediate-done)
   :map minibuffer-local-map
   ("C-r" . counsel-minibuffer-history)))

;; flycheck -- check syntax
(use-package flycheck
  :ensure t
  :config
  (setq truncate-lines nil) ; 如果单行信息很长会自动换行
  :hook
  (prog-mode . flycheck-mode))

;; company-mode
(use-package company
  :ensure t
  :init (global-company-mode)
  :config
  (setq company-minimum-prefix-length 1) ; 只需敲 1 个字母就开始进行自动补全
  (setq company-tooltip-align-annotations t)
  (setq company-idle-delay 0.0)
  (setq company-show-numbers t) ;; 给选项编号 (按快捷键 M-1、M-2 等等来进行选择).
  (setq company-selection-wrap-around t)
  (setq company-transformers '(company-sort-by-occurrence))) ; 根据选择的频率进行排序，读者如果不喜欢可以去掉

;;; GUI company-box
;(use-package company-box
;  :ensure t
;  :if window-system
;  :hook (company-mode . company-box-mode))

;; AI auto-complete
(use-package company-tabnine
  :ensure t
  :init (add-to-list 'company-backends #'company-tabnine))

;; snippets
(use-package yasnippet
  :ensure t
  :hook
  (prog-mode . yas-minor-mode)
  :config
  (yas-reload-all)
  ;; add company-yasnippet to company-backends
  (defun company-mode/backend-with-yas (backend)
    (if (and (listp backend) (member 'company-yasnippet backend))
	backend
      (append (if (consp backend) backend (list backend))
              '(:with company-yasnippet))))
  (setq company-backends (mapcar #'company-mode/backend-with-yas company-backends))
  ;; unbind <TAB> completion
  (define-key yas-minor-mode-map [(tab)]        nil)
  (define-key yas-minor-mode-map (kbd "TAB")    nil)
  (define-key yas-minor-mode-map (kbd "<tab>")  nil)
  :bind
  (:map yas-minor-mode-map ("S-<tab>" . yas-expand)))

(use-package yasnippet-snippets
  :ensure t
  :after yasnippet)

(global-set-key (kbd "M-/") 'hippie-expand)




;;; other utilities

;; dashboard
(use-package dashboard
  :ensure t
  :config
  (setq dashboard-banner-logo-title "Keep Calm && Carry On") ;; 个性签名，随读者喜好设置
  ;; (setq dashboard-projects-backend 'projectile) ;; 读者可以暂时注释掉这一行，等安装了 projectile 后再使用
  (setq dashboard-startup-banner 'official)  ; 也可以自定义图片
  (setq dashboard-items '((recents  . 5)     ; 显示多少个最近文件
			  (bookmarks . 5)    ; 显示多少个最近书签
			  (projects . 10)))  ; 显示多少个最近项目
  (dashboard-setup-startup-hook))

;; rainbow-delimiters
(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

;; mode line prettier
(use-package smart-mode-line
  :ensure t
  :init
  (setq sml/no-confirm-load-theme t)
  (sml/setup))

;; smooth scrooling
(use-package good-scroll
  :ensure t
  :if window-system          ; 在图形化界面时才使用这个插件
  :init (good-scroll-mode))

;; window switcher
(use-package ace-window
  :ensure t
  :bind (("C-x o" . 'ace-window)))

(provide 'packages-config)

;;; packages-config.el ends here
