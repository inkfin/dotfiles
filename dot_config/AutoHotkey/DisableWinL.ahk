#Requires AutoHotkey v2.0

; <https://stackoverflow.com/questions/19321693/autohotkey-remap-key-with-winl-functionality>
; Disable win + l key locking (This line must come before any hotkey assignments in the .ahk file)
RegWrite(1, "REG_DWORD", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System", "DisableLockWorkstation")
