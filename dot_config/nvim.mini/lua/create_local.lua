-- lua/local.lua  –  per-machine feature switches
--
-- Comment out or set to `false` to disable a language config.

local M = {}

-- ─── Language-server configs (lua/lang/*.lua) ───────────────────────────────
M.lang = {
    c      = true,
    lua_ls = true,
    python = true,
    -- rust   = true,
    -- go     = true,
}

-- ─── UI feature switches ─────────────────────────────────────────────────────
M.transparent = true   -- transparent terminal background
M.mini_clue   = true   -- which-key style keymap popup (mini.clue)

return M
