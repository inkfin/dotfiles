-- ~/.config/nvim.lazyvim/lua/plugins/utils/codecompanion.lua
-- CodeCompanion: AI chat + inline interaction (replaces Copilot Chat).
--
-- Gated via `_G.disable_plugins.codecompanion` (false = enabled).
-- Adapter config (url / api_key / model) is read from
-- `_G.ai_config.codecompanion` — set it in per-machine local_config.lua,
-- NEVER in source.
--
-- Per-machine local_config.lua example (DeepSeek):
--   _G.ai_config = {
--     codecompanion = {
--       url      = "https://api.deepseek.com",
--       api_key  = "DEEPSEEK_API_KEY",   -- env var name
--       chat_url = "/v1/chat/completions",
--       model    = "deepseek-chat",
--     },
--   }

local ad = (_G.ai_config and _G.ai_config.codecompanion) or {}

return {
    "olimorris/codecompanion.nvim",
    enabled = not _G.disable_plugins.codecompanion,
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
        adapters = {
            http = {
                my_remote = function()
                    return require("codecompanion.adapters").extend("openai_compatible", {
                        env = {
                            url      = ad.url      or "https://api.openai.com/v1",
                            api_key  = ad.api_key  or "OPENAI_API_KEY",
                            chat_url = ad.chat_url or "/chat/completions",
                        },
                        schema = {
                            model = { default = ad.model or "gpt-4o" },
                        },
                    })
                end,
            },
        },
        interactions = {
            chat   = { adapter = "my_remote" },
            inline = { adapter = "my_remote" },
            cmd    = { adapter = "my_remote" },
        },
    },
    keys = {
        { "<leader>aa", "<cmd>CodeCompanionActions<cr>",      mode = { "n", "v" }, desc = "CodeCompanion Actions" },
        { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>",  mode = { "n", "v" }, desc = "CodeCompanion Chat" },
        { "<leader>ae", "<cmd>CodeCompanionChat Add<cr>",     mode = "v",          desc = "CodeCompanion Add to Chat" },
    },
    init = function()
        vim.cmd([[cab cc CodeCompanion]])
    end,
}
