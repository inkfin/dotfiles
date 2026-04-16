-- ~/.config/nvim.mini/lua/lang/c3.lua
-- C3 LSP configuration
-- Server: c3_lsp (binary: c3lsp)

local lsp = require("lsp_util")

local M = {
    -- Mason ships this package as `c3-lsp`, while nvim-lspconfig exposes the
    -- server as `c3_lsp`, so this language uses the raw Mason package path.
    mason_packages = { "c3-lsp" },
}

function M.setup()
    lsp.setup("c3_lsp", {
        cmd = { "c3lsp" },
        root_markers = {
            "project.json",
            "manifest.json",
            ".git",
        },
    })
end

return M
