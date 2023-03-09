;;; keybindings-config.el -- user custom keybindings
;;; Commentary:
;;; Code:

; (global-set-key (kbd <KEY>) <FUNCTION>)

(global-set-key (kbd "RET") 'newline-and-indent)

(global-set-key (kbd "M-w") 'kill-region)              ; 交换 M-w 和 C-w，M-w 为剪切
(global-set-key (kbd "C-w") 'kill-ring-save)           ; 交换 M-w 和 C-w，C-w 为复制
(global-set-key (kbd "C-a") 'back-to-indentation)      ; 交换 C-a 和 M-m，C-a 为到缩进后的行首
(global-set-key (kbd "M-m") 'move-beginning-of-line)   ; 交换 C-a 和 M-m，M-m 为到真正的行首
(global-set-key (kbd "C-c '") 'comment-or-uncomment-region) ; 为选中的代码加注释/去注释

;; Faster move cursor
(defun next-five-lines()
  "Move cursor to next 10 lines."
  (interactive)
  (next-line 5))

(defun previous-five-lines()
  "Move cursor to previous 10 lines."
  (interactive)
  (previous-line 5))

(global-set-key (kbd "M-n") 'next-five-lines)            ; 光标向下移动 5 行
(global-set-key (kbd "M-p") 'previous-five-lines)        ; 光标向上移动 5 行

;; Orgmode keybindings
(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)

(provide 'keybindings-config)

;;; keybindings-config.el ends here
