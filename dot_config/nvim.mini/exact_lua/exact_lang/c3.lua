-- ~/.config/nvim.mini/lua/lang/c3.lua
-- C3 LSP configuration
-- Server: c3_lsp (binary: c3lsp)

local lsp = require("lsp_util")

lsp.setup("c3_lsp", {
    cmd = { "c3lsp" },
    root_markers = {
        "project.json",
        "manifest.json",
        ".git",
    },
})
