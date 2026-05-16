-- ~/.config/nvim.mini/lua/plugins/conform.lua
-- External formatter bridge for filetypes that don't have an LSP formatter.
--
-- Formatter strategy:
-- - Use conform.nvim's normal executable lookup.
-- - Let Mason manage the small default toolset for this config.
-- - Let conform fall back to LSP formatting for languages that already have a
--   formatter-capable server.
--
-- prettierd is the closest thing to a simple "one formatter for common text
-- files" in this config. It covers JSON/YAML/Markdown well, but TOML still
-- wants taplo.

require("pack").add("https://github.com/stevearc/conform.nvim")

local ok, conform = pcall(require, "conform")
if not ok then return end

conform.setup({
    default_format_opts = {
        timeout_ms = 3000,
        async = false,
        quiet = false,
        lsp_format = "fallback",
    },
    -- Keep the default formatter surface intentionally small:
    -- prettierd handles the common structured/text files, and taplo handles
    -- TOML. Everything else falls back to LSP formatting when available.
    formatters_by_ft = {
        json  = { "prettierd" },
        jsonc = { "prettierd" },
        json5 = { "prettierd" },
        toml  = { "taplo" },
        yaml  = { "prettierd" },
        markdown = { "prettierd" },
    },
})
