return {
    { "folke/LazyVim", version = "15.x" },
    {
        "nvim-treesitter/nvim-treesitter",
        version = false, -- last release is way too old and doesn't work on Windows
        -- don't load on potato computers
        build = vim.g.potato_computer and "" or ":TSUpdate",
        opts = {
            sync_install = true,
            auto_install = true,
            prefer_git = false, -- use curl
        },
    },
}
