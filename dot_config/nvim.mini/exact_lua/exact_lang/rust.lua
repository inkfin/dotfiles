-- ~/.config/nvim.mini/lua/lang/rust.lua
-- Rust LSP configuration
-- Server: rust_analyzer

local lsp = require("lsp_util")

local M = {
    mason_lspconfig = { "rust_analyzer" },
}

function M.setup()
    lsp.setup("rust_analyzer", {
        settings = {
            ["rust-analyzer"] = {
                checkOnSave = {
                    command = "clippy",   -- use clippy instead of check
                },
                cargo = {
                    allFeatures = true,
                    loadOutDirsFromCheck = true,
                },
                procMacro = {
                    enable = true,
                },
                inlayHints = {
                    bindingModeHints          = { enable = true },
                    chainingHints             = { enable = true },
                    closingBraceHints         = { enable = true, minLines = 25 },
                    closureReturnTypeHints    = { enable = "with_block" },
                    lifetimeElisionHints      = { enable = "skip_trivial" },
                    parameterHints            = { enable = true },
                    typeHints                 = { enable = true },
                },
            },
        },
    })
end

return M
