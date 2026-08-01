-- ~/.config/nvim.mini/lua/plugins/wakatime.lua
-- WakaTime: coding time tracking.
--
-- Gated behind `require("local").wakatime` so it stays opt-in per machine.
-- Requires a WakaTime API key (~/.wakatime.cfg) once enabled.

local ok_local, local_cfg = pcall(require, "local")
if not (ok_local and local_cfg.wakatime == true) then return end

require("pack").add("https://github.com/wakatime/vim-wakatime")
