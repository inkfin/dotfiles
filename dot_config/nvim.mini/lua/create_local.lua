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

return M
