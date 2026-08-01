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
	-- Windows 11: alternative translucent effect (acrylic)
	-- win32_system_backdrop = "Acrylic",

	freetype_load_target = "Normal",

	color_scheme = "Snazzy (Gogh)",

	-- Tab bar
	tab_bar_at_bottom = true,
	use_fancy_tab_bar = false,
	hide_tab_bar_if_only_one_tab = false,

	font = wezterm.font_with_fallback(font_with_fallback),
	font_size = 11.0,
	-- Line height for readability with Iosevka
	-- line_height = 1.2,

	window_decorations = "INTEGRATED_BUTTONS|RESIZE",
	window_padding = { left = 0, right = 0, top = 0, bottom = 0 },

	-- Kitty keyboard protocol: better modifier key handling for nvim
	enable_kitty_keyboard = true,

	-- Scrollback
	scrollback_lines = 10000,

	-- Exit behavior: close tab when process exits cleanly
	exit_behavior = "CloseOnCleanExit",

	-- Auto-reload config on save
	automatically_reload_config = true,

	-- Silently ignore missing glyphs (fallback font will be used)
	warn_about_missing_glyphs = false,
}
