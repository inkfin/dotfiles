-- wezterm.lua
-- inkfin's wezterm configuration

local wezterm = require("wezterm")
Config = wezterm.config_builder()
local t = require("tools")

t.require_config("config.shell")
t.require_config("config.appearance")

require("keymaps")

return Config
