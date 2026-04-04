-- init.lua
-- Minimal Neovim config using built-in vim.pack (Neovim 0.12+)

-- Each plugin file registers its own source(s) via pack.add(), then configures
-- the plugin. pack.load() requires them in order and must come first so that
-- all vim.pack.add() calls happen before Neovim resolves the pack paths.
local pack = require("pack")

pack.load({
    -- Core editor behaviour (no external plugins needed)
    "options",
    "autocmds",

    -- Plugins (each file calls pack.add() then configures itself)
    "plugins.mini",
    "plugins.treesitter",
    "plugins.flash",
    "plugins.multicursor",
    "plugins.undotree",
    "plugins.grug-far",
    "plugins.neo-tree",
    "plugins.telescope",
    "plugins.bufferline",
    "plugins.lsp",
    "plugins.blink",
    "plugins.colorscheme",
    "plugins.pack_ext",   -- PackUpdate command + pack list UI (stopgap)
    "plugins.terminal",

    -- Keymaps last so all plugins are available
    "keymaps",
})
