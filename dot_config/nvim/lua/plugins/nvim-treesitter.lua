-- enhanced highlight plugin, see

return {
    {
        "nvim-treesitter/nvim-treesitter",
        version = false, -- last release is way too old and doesn't work on Windows
        build = vim.g.potato_computer and "" or ":TSUpdate",

        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "bash",
                "lua",
                "luadoc",
                "luap",
                "vim",
                "html",
                "javascript",
                "css",
                "typescript",
                "tsx",
                "markdown",
                "markdown_inline",
                "python",
                "regex",
                "yaml",
                "toml",
            })
            opts.sync_install = true
            opts.auto_install = true
            opts.prefer_git = false -- use curl
        end,
    },
}
