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
        auto_trigger = false, -- Don't show suggestions until the user explicitly triggers them.
        hide_during_completion = false, -- Don't hide suggestions when the completion menu is open.
        trigger_on_accept = true, -- Trigger a new suggestion with accpt key when there's no existing one.
        keymap = {
            accept = "<M-l>",
            next = "<M-]>",
            prev = "<M-[>",
            -- VS Code-like accept-next-word behavior.
            accept_word = "<M-Right>",
            accept_line = false,
            toggle_auto_trigger = false,
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
