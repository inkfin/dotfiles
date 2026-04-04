-- ~/.config/nvim.mini/lua/plugins/treesitter.lua
-- nvim-treesitter: syntax highlighting and folding

require("pack").add("https://github.com/nvim-treesitter/nvim-treesitter")

local ok, configs = pcall(require, "nvim-treesitter.configs")
if not ok then return end

configs.setup({
    -- Install parsers for these languages automatically
    ensure_installed = {
        "bash",
        "c",
        "cpp",
        "go",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "rust",
        "vim",
        "vimdoc",
    },
    highlight = { enable = true },
    indent    = { enable = true },
})
