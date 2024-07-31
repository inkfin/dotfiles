-- appearance.lua

local wezterm = require("wezterm")
local t = require("tools")

t.require_config("config.retro_tab_bar")

local font_with_fallback = {}
if t.os("windows") then
	font_with_fallback = { "IosevkaTerm NFM Medium", "JetBrains Mono" }
elseif t.os("macos") then
	font_with_fallback = { "JetBrains Mono" }
end

local window_background_opacity = 0.6
if t.os("windows") then
	window_background_opacity = 0.85
elseif t.os("macos") then
	window_background_opacity = 0.65
end

return {
	initial_cols = 96,
	initial_rows = 24,

	window_background_opacity = window_background_opacity,

	-- "VerticalLcd" "HorizontalLcd" "Normal" "Mono" "Light"
	freetype_load_target = "Normal",

	-- color_scheme = "Batman",
	color_scheme = "Snazzy (Gogh)",

	-- Tab bar settings
	-- Config.hide_tab_bar_if_only_one_tab = true
	tab_bar_at_bottom = true,
	-- retro tab bar
	use_fancy_tab_bar = false,

	font = wezterm.font_with_fallback(font_with_fallback),
	font_size = 11.0,

	window_decorations = "INTEGRATED_BUTTONS|RESIZE",
	-- enable scroll bar
	-- window_padding = { left = 0, right = 15, top = 0, bottom = 0 },
	-- enable_scroll_bar = true,
	window_padding = { left = 0, right = 0, top = 0, bottom = 0 },
}
