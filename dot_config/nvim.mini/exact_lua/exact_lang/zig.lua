-- ~/.config/nvim.mini/lua/lang/zig.lua
-- Zig LSP configuration
-- Server: zls

local lsp = require("lsp_util")

local M = {
    mason_lspconfig = { "zls" },
    treesitter = { "zig" },
}

function M.setup()
    lsp.setup("zls", {
        filetypes = { "zig", "zir" },
        root_markers = {
            "zls.json",
            "build.zig",
            ".git",
        },
    })
end

return M
