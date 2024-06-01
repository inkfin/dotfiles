local wezterm = require("wezterm")
local act = wezterm.action
local t = require("tools")

Config.leader = { key = "a", mods = "CTRL" }

t.add_key({
	key = "+", -- + is shift + "="
	mods = "ALT|SHIFT",
	action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
})

t.add_key({
	key = "_",
	mods = "ALT|SHIFT",
	action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
})

t.add_key({
	key = "F11",
	-- mods = "CTRL",
	action = wezterm.action.ToggleFullScreen,
})

for i = 1, 4 do
	local panel_loc = { "Up", "Down", "Left", "Right" }
	local keys = { "UpArrow", "DownArrow", "LeftArrow", "RightArrow" }
	t.add_key({ key = keys[i], mods = "ALT", action = act.ActivatePaneDirection(panel_loc[i]) })
	t.add_key({ key = keys[i], mods = "ALT|SHIFT", action = act.AdjustPaneSize({ panel_loc[i], 5 }) })
end

t.add_key({
	key = "W",
	mods = "CTRL|SHIFT",
	action = act.CloseCurrentPane({ confirm = false }),
})

t.add_key({ key = "O", mods = "CTRL|SHIFT", action = act.ShowLauncherArgs({ flags = "FUZZY|TABS|LAUNCH_MENU_ITEMS" }) })

t.add_key({
	key = "R",
	mods = "ALT|SHIFT",
	action = act.RotatePanes("Clockwise"),
})

-- Use ALT + 1-8 to switch tabs
for i = 1, 8 do
	t.add_key({
		key = tostring(i),
		mods = "ALT",
		action = act.ActivateTab(i - 1),
	})
end
