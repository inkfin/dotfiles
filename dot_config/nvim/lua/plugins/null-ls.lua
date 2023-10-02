return {
    "nvimtools/none-ls.nvim",
    opts = function()
        local nls = require("null-ls")
        return {
            root_dir = require("null-ls.utils").root_pattern(
                ".null-ls-root",
                ".neoconf.json",
                "Makefile",
                ".git",
                ".vscode",
                ".vim",
                ".root"
            ),
            sources = {
                nls.builtins.formatting.stylua,
                nls.builtins.formatting.shfmt,
                nls.builtins.formatting.clang_format,
                nls.builtins.formatting.rustfmt,
                nls.builtins.formatting.prettier.with({
                    disabled_filetypes = { "markdown", "typescript" },
                    timeout = 30000,
                }),
                nls.builtins.formatting.markdownlint.with({
                    timeout = 30000,
                }),
            },
            -- debug = true,
        }
    end,
}
