-- init.lua
-- Minimal Neovim config using built-in vim.pack (Neovim 0.12+)

local pack = require("pack")

-- Core editor settings (no plugins, loaded directly)
require("options")
require("autocmds")

-- Plugin modules: each calls pack.add() then configures itself.
pack.load({
    "plugins.mini",       -- mini.icons must load before snacks dashboard renders
    "plugins.gitsigns",
    "plugins.snacks",
    "plugins.noice",
    "plugins.markup",
    "plugins.treesitter",
    "plugins.flash",
    "plugins.marks",
    "plugins.multicursor",
    "plugins.undotree",
    "plugins.picker",
    "plugins.bufferline",
    "plugins.lualine",
    "plugins.conform",
    "plugins.lsp",
    "plugins.copilot",
    "plugins.blink",
    "plugins.trouble",
    "plugins.colorscheme",
    "plugins.pack_ext",
    "plugins.terminal",
    "plugins.which-key",
    "plugins.explorer",
    "plugins.dap",
})

-- Keymaps last so all plugins are available
require("keymaps")
