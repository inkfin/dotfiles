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


