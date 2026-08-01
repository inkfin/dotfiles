-- shell.lua
local wezterm = require("wezterm")
local t = require("tools")
local config = {}

-- Detect nushell binary per-platform
local function find_nu()
	if t.os("windows") then
		local home = wezterm.home_dir
		return { home .. "/AppData/Local/Programs/nu/bin/nu.exe" }
	elseif t.os("macos") then
		return { "/opt/homebrew/bin/nu" }
	else
		return { "/usr/bin/nu" }
	end
end

if t.os("windows") then
	t.merge_table(config, {
		default_prog = find_nu(),

		launch_menu = {
			{
				label = "Nushell",
				args = find_nu(),
			},
			{
				label = "PowerShell 7",
				args = { "pwsh.exe", "-NoLogo" },
			},
			{
				label = "Windows PowerShell",
				args = { "C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe" },
			},
			{ label = "CMD", args = { "cmd.exe" } },
			{
				label = "Git Bash",
				args = { "C:/Program Files/Git/bin/bash.exe", "-l" },
			},
		},
	})
elseif t.os("macos") then
	t.merge_table(config, {
		default_prog = find_nu(),
		launch_menu = {
			{ label = "Nushell", args = find_nu() },
			{ label = "zsh", args = { "/bin/zsh", "-l" } },
			{ label = "bash", args = { "/bin/bash", "-l" } },
			{ label = "fish", args = { "/opt/homebrew/bin/fish" } },
		},
	})
else
	t.merge_table(config, {
		launch_menu = {
			{ label = "Nushell", args = find_nu() },
			{ label = "zsh", args = { "/usr/bin/zsh" } },
			{ label = "bash", args = { "/usr/bin/bash" } },
			{ label = "fish", args = { "/usr/bin/fish" } },
		},
	})
end

return config
