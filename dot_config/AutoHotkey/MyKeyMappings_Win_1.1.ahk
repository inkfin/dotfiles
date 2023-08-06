#Requires AutoHotkey v1.1
#InstallKeybdHook


;===========CapsLock 改键==========o

SetCapsLockState AlwaysOff

; CapsLock 短按esc，长按ctrl
; FIXME: This won't work
*CapsLock::
    KeyWait, CapsLock, T0.1
    if (ErrorLevel = 1) {
        ; Msgbox, long term pressing.
        SendEvent {Ctrl down}
        KeyWait, CapsLock
        ; Msgbox, key up
        SendEvent {Ctrl up}
    }
    else
        ; Msgbox, short term pressing.
        Send {Esc}
return


; Ctrl + CapsLock 切换大小写
^CapsLock::
If GetKeyState("CapsLock", "T") = 1
    SetCapsLockState, AlwaysOff
Else
    SetCapsLockState, AlwaysOn
Return

CapsLock::Send {ESC}




/*
; 像macOS一样的光标移动方式 
^Left::Send {Home}
^Right::Send {End}
!Left::Send ^{Left}
!Right::Send ^{Right}

^BackSpace::Send +{Home}{BackSpace}
!BackSpace::Send ^{BackSpace}


; 常用 Ctrl 组合键
CapsLock & f::Send ^{f}
CapsLock & s::Send ^{s}

CapsLock & Space::Send ^{Space}

; 使用 CapsLock + hjkl 移动
CapsLock & h::Send {Left}
CapsLock & j::Send {Down}
CapsLock & k::Send {Up}
CapsLock & l::Send {Right}
CapsLock & a::Send {Home}
CapsLock & e::Send {End}

CapsLock & b::Send ^{Left}
CapsLock & w::Send ^{Right}
CapsLock & d::Send {PgDn}
CapsLock & u::Send {PgUp}

; 防误触
CapsLock & q::q
CapsLock & r::r
CapsLock & i::i 
CapsLock & z::z

*/



/*
; 模拟macOS的Capslock，短按切换中英文，长按切换大小写

SetStoreCapslockMode, Off

timelapse := 300
CapsLock::
    KeyWait, CapsLock
    If GetKeyState("CapsLock", "T") = 0
        If (A_TimeSinceThisHotkey > timelapse)
            ; 大写关闭状态并且长按
            SetTimer, mainp, -1
        Else
            ; 大写关闭并且短按
            Send ^{Space}
    Else
        If (A_TimeSinceThisHotkey < timelapse)
            ; 大写打开状态并且短按
            SetTimer, mainp, -1
        
    
Return

mainp:
    Send, {CapsLock}
Return
*/
