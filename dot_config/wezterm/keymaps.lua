local wezterm = require("wezterm")
Config = Config or {}
local act = wezterm.action
local t = require("tools")

Config.leader = { key = "a", mods = "ALT" }
Config.keys = {}

-- Pane splits
t.add_key({
	key = "+",
	mods = "ALT|SHIFT",
	action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
})
t.add_key({
	key = "_",
	mods = "ALT|SHIFT",
	action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
})

-- Fullscreen
t.add_key({ key = "F11", action = act.ToggleFullScreen })

-- Pane navigation: Alt+Arrow to move, Alt+Shift+Arrow to resize
for i = 1, 4 do
	local panel_loc = { "Up", "Down", "Left", "Right" }
	local keys = { "UpArrow", "DownArrow", "LeftArrow", "RightArrow" }
	t.add_key({ key = keys[i], mods = "ALT", action = act.ActivatePaneDirection(panel_loc[i]) })
	t.add_key({ key = keys[i], mods = "ALT|SHIFT", action = act.AdjustPaneSize({ panel_loc[i], 5 }) })
end

-- Quick pane zoom toggle (maximize current pane)
t.add_key({ key = "Z", mods = "ALT|SHIFT", action = act.TogglePaneZoomState })

-- Close pane
t.add_key({ key = "W", mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = false }) })

-- Tab switching with Alt+1..8
for i = 1, 8 do
	t.add_key({ key = tostring(i), mods = "ALT", action = act.ActivateTab(i - 1) })
end

-- New tab in current domain
t.add_key({ key = "T", mods = "ALT|SHIFT", action = act.SpawnTab("CurrentPaneDomain") })

-- Rotate panes
t.add_key({ key = "R", mods = "ALT|SHIFT", action = act.RotatePanes("Clockwise") })

-- Launcher (fuzzy find tabs, windows, launch menu)
t.add_key({ key = "O", mods = "CTRL|SHIFT", action = act.ShowLauncherArgs({ flags = "FUZZY|TABS|LAUNCH_MENU_ITEMS" }) })

-- Tab navigator
t.add_key({ key = "B", mods = "CTRL|SHIFT", action = act.ShowTabNavigator })

-- Search scrollback
t.add_key({ key = "F", mods = "CTRL|SHIFT", action = act.Search("CurrentSelectionOrEmptyString") })

-- Copy mode
t.add_key({ key = "X", mods = "CTRL|SHIFT", action = act.ActivateCopyMode })

-- Quick select (URLs, paths, etc.)
t.add_key({ key = "U", mods = "CTRL|SHIFT", action = act.QuickSelect })

-- Scroll to bottom (useful after nvim exits)
t.add_key({ key = "L", mods = "CTRL|SHIFT", action = act.ScrollToBottom })

-- Workspace switching
for i = 1, 5 do
	t.add_key({
		key = tostring(i),
		mods = "CTRL|ALT",
		action = act.SwitchToWorkspace({ name = "workspace-" .. tostring(i) }),
	})
end

-- Leader key sequences (Alt+a then key)
t.add_key({ key = "p", mods = "LEADER", action = act.ActivateCommandPalette })
t.add_key({ key = "c", mods = "LEADER", action = act.ActivateCopyMode })
t.add_key({ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) })
t.add_key({ key = "z", mods = "LEADER", action = act.TogglePaneZoomState })
t.add_key({ key = "n", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") })
t.add_key({ key = "r", mods = "LEADER", action = act.ReloadConfiguration })
