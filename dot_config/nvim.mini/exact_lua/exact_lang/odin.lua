-- ~/.config/nvim.mini/lua/lang/odin.lua
-- Odin LSP configuration
-- Server: ols

local lsp = require("lsp_util")

local M = {
    mason_lspconfig = { "ols" },
    treesitter = { "odin" },
}

function M.setup()
    lsp.setup("ols", {
        filetypes = { "odin" },
        root_markers = {
            "ols.json",
            "*.odin",
            ".git",
        },
    })
end

return M
