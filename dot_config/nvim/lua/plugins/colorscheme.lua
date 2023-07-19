return {
    -- { "Mofiqul/dracula.nvim", version = "*" },
    {
        "LazyVim/LazyVim",
        opts = {
            -- colorscheme = "dracula",
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = function()
            return { theme = "onedark" }
        end,
    },
}
