-- shell.lua
local wezterm = require("wezterm")
local t = require("tools")

if t.os("windows") then
	return {
		default_prog = { "pwsh.exe", "-NoLogo" },

		launch_menu = {
			{ label = "PowerShell", args = { "C:/Program Files/PowerShell/7/pwsh.EXE" } },
			{ label = "WindowsPowerShell", args = { "C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe" } },
			-- {
			-- 	label = "MINGW64 / MSYS2",
			-- 	args = { "C:/msys64/msys2_shell.cmd", "-defterm", "-here", "-no-start", "-shell", "zsh", "-mingw64" },
			-- },
			-- {
			-- 	label = "MSYS / MSYS2",
			-- 	args = { "C:/msys64/msys2_shell.cmd", "-defterm", "-here", "-no-start", "-shell", "zsh", "-msys" },
			-- },
			{ label = "CMD", args = { "cmd.exe" } },
		},
	}
end
