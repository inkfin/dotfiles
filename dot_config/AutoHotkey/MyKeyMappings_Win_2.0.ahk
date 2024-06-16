#Requires AutoHotkey v2.0

#SingleInstance  ; Allow only one instance of this script to be running.
Persistent

;==============CapsLock 改键==============
; 短按 CapsLock 为 Esc, 长按 CapsLock 为 Ctrl

^Esc:: {
    if (GetKeyState("Ctrl", "P") && GetKeyState("Shift", "P")) {
        Send("^+{Esc}")
    } else {
        if GetKeyState("CapsLock", "T") {
            SetCapsLockState("Off")
        } else {
            SetCapsLockState("On")
        }
    }
}

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

;^#z:: {
;    terminalTitle := "popup"
;    DetectHiddenWindows True
;
;    if WinExist(terminalTitle) {
;        ;MsgBox "terminal already exists"
;        DetectHiddenWindows False
;
;        if WinExist(terminalTitle) {
;            ;MsgBox "terminal is not hidden"
;            WinHide terminalTitle
;        } else {
;            ;MsgBox "terminal is hidden"
;            WinShow terminalTitle
;            WinActivate terminalTitle
;            WinMaximize terminalTitle
;        }
;    } else {
;        ;MsgBox "terminal does not exist"
;        Run "wt.exe -Mf -p `"PowerShell 7 (popup)`""
;        WinWait terminalTitle
;        if WinExist(terminalTitle) {
;            WinActivate terminalTitle
;            WinMaximize terminalTitle
;        }
;    }
;    return
;}

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


;==============Hotkey Window============
;;; Ctrl + Win + ` toggle terminal window
^#`:: {
    DetectHiddenWindows True
    ; alacritty executable:
    exeName := "alacritty.exe"
    ; there's no $HOME (eww...)
    exeArgs := " --config-file " . A_AppData . "/../../.config/alacritty/profiles/windows/transparent_fullscreen.toml"

    terminalTitle := "popup" ; detect exact window title
    ;terminalTitle := "ahk_exe " exeName ; detect all backgroud exe
    if WinExist(terminalTitle) { ; Check if a window with your program exists
        DetectHiddenWindows False ; Disable hidden window check to see if is currently hidden, otherwise won't work
        if WinActive(terminalTitle) { ; Check if the window is active
            WinHide(terminalTitle) ; If the window is active, hide it
        } else {
            WinShow(terminalTitle) ; If the window is not active (hidden or in the background), show it
            WinActivate(terminalTitle) ; Activate the window
        }
    } else {
        Run(exeName " " exeArgs) ; If the window does not exist, launch the program
    }
    DetectHiddenWindows False
    return
}


;=======================================
;;; Manually fetch *ANY* hotkey hidden window

;;; Win + Ctrl + A to save current window
;#^A:: StoreWindowID("Z")
#^S:: StoreWindowID("X")
#^D:: StoreWindowID("C")

;;; Win + Ctrl + Z to toggle hidden window
;#^Z:: ToggleWindow("Z")
#^X:: ToggleWindow("X")
#^C:: ToggleWindow("C")

;;; Implementation
global StoredWindowIDMap := Map()


StoreWindowID(KeyName) {
    global StoredWindowIDMap
    DetectHiddenWindows true
    TrayTipTitle := "Hidden Window Helper"

    ActiveID := WinGetID("A")

    ; Release window if has previous stored window
    if (StoredWindowIDMap.Has(KeyName)) {
        StoredWindowID := StoredWindowIDMap[KeyName]
        if (WinExist("ahk_id " . StoredWindowID) && StoredWindowID != ActiveID) {
            WinShow("ahk_id " . StoredWindowID)
            WinActivate("ahk_id " . StoredWindowID)
        }
    }

    StoredWindowIDMap[KeyName] := ActiveID

    TrayTip "Window " WinGetTitle("A") " is bind to " KeyName ".", TrayTipTitle, 1
    DetectHiddenWindows false
    return
}

ToggleWindow(KeyName) {
    global StoredWindowIDMap
    DetectHiddenWindows true

    TrayTipTitle := "Hidden Window Helper"

    if (StoredWindowIDMap.Has(KeyName)) {
        windowID := StoredWindowIDMap[KeyName]
        if WinExist("ahk_id " . windowID) {
            if DllCall("IsWindowVisible", "Ptr", windowID) {
                WinHide("ahk_id " . windowID)
                ;TrayTip "Window with ID " . windowID . " hidden.", TrayTipTitle
            } else {
                WinShow("ahk_id " . windowID)
                WinActivate("ahk_id " . windowID)
                ;TrayTip "Window with ID " . windowID . " shown.", TrayTipTitle
            }
        } else {
            TrayTip("The saved window no longer exists.", TrayTipTitle, 2)
            StoredWindowIDMap.Delete(KeyName)  ; Clear saved window ID
        }
    } else {
        TrayTip("No window is bind to " KeyName ".", TrayTipTitle, "Mute")
    }

    DetectHiddenWindows false
    return
}

; Release all window before exit
OnExit UnHideAll

UnHideAll(*) {
    global StoredWindowIDMap
    for KeyName, StoredWindowID in StoredWindowIDMap {
        if (StoredWindowID != "" && WinExist("ahk_id " . StoredWindowID)) {
            WinShow("ahk_id " . StoredWindowID)
            WinActivate("ahk_id " . StoredWindowID)
        }
    }
    StoredWindowIDMap.Clear()  ; Clear all keys
}
