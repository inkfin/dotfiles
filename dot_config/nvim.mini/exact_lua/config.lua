-- ~/.config/nvim.mini/lua/config.lua
-- User-tunable constants referenced by autocmds.lua, plugins, etc.

local M = {}

-- Project root markers (used by root_lcd autocmd and neo-tree)
M.root_patterns = {
    ".git",
    ".svn",
    ".hg",
    "Makefile",
    "CMakeLists.txt",
    "package.json",
    "pyproject.toml",
    "Cargo.toml",
    "go.mod",
}

-- Per-filetype indent widths
-- Any filetype not listed falls back to the global shiftwidth in options.lua
M.indent = {
    -- 2-space filetypes
    quarto     = 2,
    javascript = 2,
    typescript = 2,
    html       = 2,
    css        = 2,
    nu         = 2,
    -- 4-space filetypes
    markdown   = 4,
    json       = 4,
    cpp        = 4,
    c          = 4,
    python     = 4,
    rust       = 4,
    cmake      = 4,
    norg       = 4,
}

-- Format is always manual (never triggered automatically on save).
-- Set to true to re-enable autoformat globally.
M.autoformat = false

return M
