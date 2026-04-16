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

-- ─── LSP UI switches ─────────────────────────────────────────────────────────
M.lsp = {
    references = "loclist", -- LSP list UI: builtin loclist or fzf-lua picker
}

return M
