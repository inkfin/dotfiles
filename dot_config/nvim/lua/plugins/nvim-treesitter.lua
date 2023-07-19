-- enhanced highlight plugin, see

return {
    {
        "nvim-treesitter",
        version = false, -- last release is way too old and doesn't work on Windows
        config = function()
            -- Use curl instead of git, see https://github.com/nvim-treesitter/nvim-treesitter/wiki/Windows-support for more information
            require("nvim-treesitter.install").prefer_git = false
        end,
        ---@type TSConfig
        opts = {
            ensure_installed = {
                "bash",
                "c",
                "cpp",
                "html",
                "javascript",
                "css",
                "typescript",
                "tsx",
                "markdown",
                "makrdown_inline",
                "lua",
                "luadoc",
                "luap",
                "vim",
                "python",
                "regex",
                "yaml",
                "toml",
                "go",
                "rust",
            },
        },
    },
}
