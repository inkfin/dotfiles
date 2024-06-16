-- appearance.lua

local wezterm = require("wezterm")
local t = require("tools")

t.require_config("config.retro_tab_bar")

return {
	initial_cols = 96,
	initial_rows = 24,

	window_background_opacity = 0.55,

	-- "VerticalLcd" "HorizontalLcd" "Normal" "Mono" "Light"
	freetype_load_target = "Normal",

	-- color_scheme = "Batman",
	color_scheme = "Snazzy (Gogh)",

	-- Tab bar settings
	-- Config.hide_tab_bar_if_only_one_tab = true
	tab_bar_at_bottom = true,
	-- retro tab bar
	use_fancy_tab_bar = false,

	font = wezterm.font_with_fallback({ "JetBrains Mono" }),
	font_size = 11.0,

	window_decorations = "INTEGRATED_BUTTONS|RESIZE",
	-- enable scroll bar
	-- window_padding = { left = 0, right = 15, top = 0, bottom = 0 },
	-- enable_scroll_bar = true,
	window_padding = { left = 0, right = 0, top = 0, bottom = 0 },
}
