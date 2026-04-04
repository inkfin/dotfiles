-- ~/.config/nvim.mini/lua/plugins/colorscheme.lua
-- Theme: tokyonight.nvim

require("pack").add("https://github.com/folke/tokyonight.nvim")

local ok, tokyonight = pcall(require, "tokyonight")
if not ok then return end

tokyonight.setup({
    style         = "night",   -- night | storm | moon | day
    light_style   = "day",
    transparent   = true,
    terminal_colors = true,

    styles = {
        comments  = { italic = true },
        keywords  = { italic = true },
        functions = {},
        variables = {},
        -- Background for sidebars (neo-tree, telescope, etc.)
        sidebars  = "dark",
        floats    = "dark",
    },

    sidebars = { "neo-tree", "qf", "help", "terminal" },

    on_highlights = function(hl, c)
        -- Make inlay hints less intrusive (matches our autocmd colour)
        hl.LspInlayHint = { fg = c.dark5, bg = "NONE" }
    end,
})

vim.cmd.colorscheme("tokyonight")
