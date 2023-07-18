return {
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require('lualine').setup()
        end,
        options = { theme = 'gruvbox' },
    },
    {
        "nvim-treesitter",
        config = function()
            -- Use curl instead of git, see https://github.com/nvim-treesitter/nvim-treesitter/wiki/Windows-support for more information
            require "nvim-treesitter.install".prefer_git = false
        end,
    }
}
