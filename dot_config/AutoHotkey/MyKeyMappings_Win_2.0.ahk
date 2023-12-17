#Requires AutoHotkey v2.0

;==============CapsLock 改键==============
; 短按 CapsLock 为 Esc, 长按 CapsLock 为 Ctrl

^Esc::CapsLock

*CapsLock:: {
    if A_PriorKey = "LControl" {
        ;ToolTip "Prior key was LControl"
        ; 下面添加的{blind}{sc0x0EA}的功能是打断 ctrl 的连击
        SendInput("{blind}{sc0x0EA}")
    }
    if !GetKeyState("ctrl") {
        ;ToolTip "Ctrl is not down, sending Ctrl Down"
        Send("{Blind}{Ctrl Down}")
    }
    SetTimer(CheckCapsLockFunction, 100)
}

; 计时器避免松开Capslock以后仍然按下ctrl
CheckCapsLockFunction() {
    if !GetKeyState("CapsLock", "P") {
        Send("{Blind}{Ctrl Up}")
        SetTimer(CheckCapsLockFunction, 0)
    }
}

CapsLock up:: {
    Send("{Blind}{Ctrl Up}")
    if A_PriorKey = "CapsLock" {
        ;ToolTip "Prior key was CapsLock, sending Esc"
        ; 这里发送 ctrl up 的目的是防止出现 ^esc 组合键出现 LWin 的效果, 这里必须是 blind, 不然会导致 win 的出现
        Send("{Blind}{Ctrl Up}")
        Send("{esc}")
    } 
    if GetKeyState("ctrl") {
        ;ToolTip "Ctrl is down, sending Ctrl Up"
        Send("{Blind}{Ctrl Up}")
    }
}


;;; Hotkey for launching terminal

^#z:: {
    terminalTitle := "popup"
    DetectHiddenWindows True

    if WinExist(terminalTitle) {
        ;MsgBox "terminal already exists"
        DetectHiddenWindows False

        if WinExist(terminalTitle) {
            ;MsgBox "terminal is not hidden"
            WinHide terminalTitle
        } else {
            ;MsgBox "terminal is hidden"
            WinShow terminalTitle
            WinMaximize terminalTitle
        }
    } else {
        ;MsgBox "terminal does not exist"
        Run "wt.exe -Mf -p `"PowerShell 7`" --title " terminalTitle
        WinWait terminalTitle
        if WinExist(terminalTitle) {
            WinActivate terminalTitle
            WinMaximize terminalTitle
        }
    }
    return
}

;;; see window properties
;SetTimer WatchCursor, 100

WatchCursor()
{
    MouseGetPos , , &id, &control
    ToolTip
    (
        "ahk_id " id "
        ahk_class " WinGetClass(id) "
        " WinGetTitle(id) "
        Control: " control
    )
}
