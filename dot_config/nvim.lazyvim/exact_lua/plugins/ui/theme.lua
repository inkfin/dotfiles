return {
    -- Turn tokyonight to transparent
    {
        "folke/tokyonight.nvim",
        opts = {
            transparent = true,
            styles = {
                sidebars = "transparent",
                floats = "transparent",
            },
        },
    },
    -- { "Mofiqul/dracula.nvim", version = false },
    -- { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
    {
        "LazyVim/LazyVim",
        opts = {
            ---- dark scheme
            colorscheme = "tokyonight",
            -- colorscheme = "catppuccin",
            -- colorscheme = "catppuccin-mocha",
            -- colorscheme = "dracula",
            ---- light scheme
            -- colorscheme = "catppuccin-latte"
        },
    },
}
