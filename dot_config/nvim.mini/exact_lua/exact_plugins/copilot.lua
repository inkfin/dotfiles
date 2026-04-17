-- ~/.config/nvim.mini/lua/plugins/copilot.lua
-- GitHub Copilot inline suggestions.
--
-- This stays behind `require("local").ai.copilot` so AI features can be
-- enabled per machine without changing the shared plugin list.

local ok_local, local_cfg = pcall(require, "local")
local ai_cfg = ok_local and local_cfg.ai or {}
if ai_cfg.copilot ~= true then return end

require("pack").add("https://github.com/zbirenbaum/copilot.lua")

local ok, copilot = pcall(require, "copilot")
if not ok then return end

copilot.setup({
    suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = false,
        keymap = {
            -- Keep Copilot's default navigation/dismiss bindings and only move
            -- the accept action off <Tab> so blink/LSP completion stays separate.
            accept = "<M-l>",
        },
    },
    panel = {
        enabled = false,
        auto_refresh = true,
    },
    filetypes = {
        markdown = true,
    },
})

-- blink.cmp and Copilot suggestions both draw inline UI near the cursor.
-- Hide Copilot while blink's menu is open so the two completion UIs do not
-- overlap, then restore Copilot once the menu closes.
local blink_copilot_group = vim.api.nvim_create_augroup("nvim_mini_blink_copilot", { clear = true })

vim.api.nvim_create_autocmd("User", {
    group = blink_copilot_group,
    pattern = "BlinkCmpMenuOpen",
    callback = function()
        local ok_suggestion, suggestion = pcall(require, "copilot.suggestion")
        if not ok_suggestion then return end

        suggestion.dismiss()
        vim.b.copilot_suggestion_hidden = true
    end,
})

vim.api.nvim_create_autocmd("User", {
    group = blink_copilot_group,
    pattern = "BlinkCmpMenuClose",
    callback = function()
        vim.b.copilot_suggestion_hidden = false
    end,
})

vim.keymap.set("n", "<leader>ua", function()
    local disabled = false
    local ok_client, client = pcall(require, "copilot.client")
    if ok_client and type(client.is_disabled) == "function" then
        disabled = client.is_disabled()
    end

    vim.cmd(disabled and "Copilot enable" or "Copilot disable")
    vim.notify(disabled and "Enabled Copilot" or "Disabled Copilot")
end, {
    silent = true,
    desc = "Toggle Copilot",
})
