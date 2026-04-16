-- ~/.config/nvim.mini/lua/lang/proto.lua
-- Protobuf LSP configuration
-- Server: buf_ls (provided by the Buf CLI)

local lsp = require("lsp_util")

local M = {
    -- mason-lspconfig can install and map `buf_ls` directly.
    mason_lspconfig = { "buf_ls" },
    treesitter = { "proto" },
}

function M.setup()
    lsp.setup("buf_ls", {
        -- Buf modules can be rooted by either a workspace file or a module file.
        -- Including `.git` keeps ad-hoc repos working when Buf metadata is absent.
        root_markers = {
            "buf.work.yaml",
            "buf.yaml",
            ".git",
        },
    })
end

return M
