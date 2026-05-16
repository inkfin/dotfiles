-- ~/.config/nvim.mini/lua/lang/markdown.lua
-- Markdown language support via marksman.
--
-- Treesitter parsing is already enabled globally, but this language module
-- owns the Markdown LSP server so it can be switched like the other language
-- configs through `lua/local.lua`.

local lsp = require("lsp_util")

local M = {
    mason_lspconfig = { "marksman" },
}

function M.setup()
    lsp.setup("marksman", {})
end

return M
