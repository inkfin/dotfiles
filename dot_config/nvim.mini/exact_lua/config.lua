-- ~/.config/nvim.mini/lua/config.lua
-- User-tunable constants referenced by autocmds.lua, plugins, etc.

local M = {}

-- Project root markers (used by root_lcd autocmd and explorer).
-- Keep this intentionally small: explicit overrides first, then VCS, then
-- editor / workspace-local markers that can stand in for project roots.
M.root_patterns = {
    ".root", -- explicitly override root

    -- Version control
    ".git",
    ".jj",
    ".svn",
    ".hg",

    -- Editor / local workspace config
    ".lazy.lua",
    ".editorconfig",
    ".nvim.lua",
    ".vscode",
    ".zed",
    ".vs",
    ".vim",
    ".idea",
    ".direnv",
}

-- Per-filetype indent widths
-- Any filetype not listed falls back to the global shiftwidth in options.lua
M.indent = {
    -- 2-space filetypes
    json       = 2,
    html       = 2,
    css        = 2,
    -- 4-space filetypes
    markdown   = 4,
    quarto     = 4,
    javascript = 4,
    typescript = 4,
    c          = 4,
    cpp        = 4,
    python     = 4,
    rust       = 4,
    cmake      = 4,
    proto      = 4,
    nu         = 4,
}

-- Format is always manual (never triggered automatically on save).
-- Set to true to re-enable autoformat globally.
M.autoformat = false

return M
