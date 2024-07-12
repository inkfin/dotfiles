return {
    {
        "stevearc/conform.nvim",
        keys = {
            {
                "<leader>rF",
                function()
                    require("conform").format({ formatters = { "injected" } })
                end,
                mode = { "n", "v" },
                desc = "Format Injected Langs",
            },
        },
        opts = {
            formatters_by_ft = {
                lua = { "stylua" },
                fish = { "fish_indent" },
                sh = { "shfmt" },
                cpp = { "clang_format" },
                rust = { "rustfmt" },
                markdown = { "markdownlint" },
                go = { "gofumpt" },
            },
            ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
            formatters = {
                injected = {
                    ignore_errors = true,
                },
            },
        },
    },
}
