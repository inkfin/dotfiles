-- ~/.config/nvim.mini/lua/plugins/codecompanion.lua
-- CodeCompanion: AI chat + inline interaction.
--
-- Gated behind `require("local").ai.codecompanion` so AI features stay
-- per-machine, mirroring plugins/supermaven.lua.
--
-- Adapter config (url / api_key / model) is read from
-- `require("local").ai.codecompanion_adapter` — secrets live in the
-- per-machine local.lua, NEVER in source.
--
-- Per-machine local.lua example (DeepSeek):
--   ai = {
--     supermaven = true,
--     codecompanion = true,
--     codecompanion_adapter = {
--       url      = "https://api.deepseek.com",
--       api_key  = "DEEPSEEK_API_KEY",   -- env var name; CodeCompanion reads it
--       chat_url = "/v1/chat/completions",
--       model    = "deepseek-chat",
--     },
--   },
-- Other providers:
--   GLM:          url="https://open.bigmodel.cn/api/paas", chat_url="/v4/chat/completions", model="glm-4-plus"
--   SiliconFlow:  url="https://api.siliconflow.cn",        chat_url="/v1/chat/completions", model="deepseek-ai/DeepSeek-V3"

local ok_local, local_cfg = pcall(require, "local")
local ai_cfg = ok_local and local_cfg.ai or {}
if ai_cfg.codecompanion ~= true then return end

local ad = ai_cfg.codecompanion_adapter or {}

require("pack").add({
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/olimorris/codecompanion.nvim",
})

local ok, cc = pcall(require, "codecompanion")
if not ok then return end

cc.setup({
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
})

vim.keymap.set({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<cr>",
    { silent = true, desc = "CodeCompanion Actions" })
vim.keymap.set({ "n", "v" }, "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>",
    { silent = true, desc = "CodeCompanion Chat" })
vim.keymap.set("v", "<leader>ae", "<cmd>CodeCompanionChat Add<cr>",
    { silent = true, desc = "CodeCompanion Add to Chat" })

vim.cmd([[cab cc CodeCompanion]])
