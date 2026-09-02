-- lua/local.lua  –  per-machine feature switches
--
-- Comment out or set to `false` to disable a language config.

local M = {}

-- ─── Language-server configs (lua/lang/*.lua) ───────────────────────────────
M.lang = {
    c      = true,
    -- c3     = true,
    lua_ls = true,
    markdown = true,
    -- rime   = true,
    python = true,
    -- rust   = true,
    -- go     = true,
    -- zig    = true,
    -- odin   = true,
    -- latex  = true,
    -- proto  = true,
}

-- ─── UI feature switches ─────────────────────────────────────────────────────
M.transparent = true   -- transparent terminal background
M.image = true         -- inline image rendering via snacks.image (ghostty/kitty; needs `magick` for non-PNG)

-- ─── AI feature switches ─────────────────────────────────────────────────────
-- Keep AI integrations behind explicit booleans so they can be enabled per
-- machine without deleting plugin files or changing the main plugin list.
M.ai = {
    supermaven = true,
    codecompanion = true,
    -- Adapter config for CodeCompanion (remote OpenAI-compatible endpoint).
    -- Secrets live HERE in the per-machine file, never in source.
    codecompanion_adapter = {
        -- DeepSeek:
        url      = "https://api.deepseek.com",
        api_key  = "DEEPSEEK_API_KEY",   -- env var name; CodeCompanion reads it
        chat_url = "/v1/chat/completions",
        model    = "deepseek-v4-flash",
        -- Other providers:
        --   GLM:          url="https://open.bigmodel.cn/api/paas", chat_url="/v4/chat/completions", model="glm-4-plus"
        --   SiliconFlow:  url="https://api.siliconflow.cn",        chat_url="/v1/chat/completions", model="deepseek-ai/DeepSeek-V3"
    },
}

-- ─── LSP UI switches ─────────────────────────────────────────────────────────
M.lsp = {
    references = "loclist", -- LSP list UI: window-local list or snacks picker
}

-- ─── Optional tools ───────────────────────────────────────────────────────────
M.wakatime = false   -- coding time tracking (needs ~/.wakatime.cfg with API key)

return M
