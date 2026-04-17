-- lua/local.lua  –  per-machine feature switches
--
-- Comment out or set to `false` to disable a language config.

local M = {}

-- ─── Language-server configs (lua/lang/*.lua) ───────────────────────────────
M.lang = {
    c      = true,
    -- c3     = true,
    lua_ls = true,
    python = true,
    -- rust   = true,
    -- go     = true,
    -- latex  = true,
    -- proto  = true,
}

-- ─── UI feature switches ─────────────────────────────────────────────────────
M.transparent = true   -- transparent terminal background

-- ─── AI feature switches ─────────────────────────────────────────────────────
-- Keep AI integrations behind explicit booleans so they can be enabled per
-- machine without deleting plugin files or changing the main plugin list.
M.ai = {
    copilot = true,
}

-- ─── LSP UI switches ─────────────────────────────────────────────────────────
M.lsp = {
    references = "loclist", -- LSP list UI: builtin loclist or fzf-lua picker
}

return M
