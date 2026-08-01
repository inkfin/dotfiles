-- ~/.config/nvim.mini/lua/plugins/supermaven.lua
-- Supermaven inline suggestions (free-tier AI completion).
--
-- Gated behind `require("local").ai.supermaven` so AI features stay
-- per-machine, mirroring plugins/codecompanion.lua.
--
-- Differences vs GitHub Copilot:
--   * No multi-suggestion cycling — Supermaven shows one suggestion at a
--     time, so <M-[> / <M-]> have no equivalent.
--   * No manual-only trigger mode; Supermaven fires on keystroke by default.

local ok_local, local_cfg = pcall(require, "local")
local ai_cfg = ok_local and local_cfg.ai or {}
if ai_cfg.supermaven ~= true then return end

require("pack").add("https://github.com/supermaven-inc/supermaven-nvim")

local ok, supermaven = pcall(require, "supermaven-nvim")
if not ok then return end

supermaven.setup({
    keymaps = {
        accept_suggestion = "<M-l>",       -- accept full suggestion
        clear_suggestion  = "<C-]>",       -- dismiss current suggestion
        accept_word       = "<M-Right>",   -- accept up to end of next word
    },
    color = {
        suggestion_color = "#7f7f7f",
        cterm            = 244,
    },
    log_level = "warn",
})

vim.keymap.set("n", "<leader>ua", function()
    local api = require("supermaven-nvim.api")
    api.toggle()
    vim.notify(api.is_running() and "Enabled Supermaven" or "Disabled Supermaven")
end, {
    silent = true,
    desc = "Toggle Supermaven",
})
