return {
    "jose-elias-alvarez/null-ls.nvim",
    opts = function()
        local nls = require("null-ls")
        local formatting = require("null-ls").builtins.formatting
        return {
            root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git"),
            sources = {
                formatting.stylua,
                formatting.shfmt,
                formatting.prettier.with({
                    disabled_filetypes = { "markdown", "typescript" },
                    timeout = 30000,
                }),
                formatting.markdownlint.with({
                    timeout = 30000,
                }),
            },
        }
    end,
}
