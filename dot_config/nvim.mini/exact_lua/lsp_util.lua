-- ~/.config/nvim.mini/lua/lsp_util.lua
-- Shared helpers for LSP configuration

local M = {}

--- Return merged capabilities: base + blink.cmp extras if available.
--- Call once per server config; result is safe to cache.
function M.capabilities()
    local base = vim.lsp.protocol.make_client_capabilities()
    local ok, blink = pcall(require, "blink.cmp")
    return ok and vim.tbl_deep_extend("force", base, blink.get_lsp_capabilities()) or base
end

--- Register and enable an LSP server.
--- @param name string   server name (matches nvim-lspconfig's name)
--- @param cfg  table    extra config merged on top of capabilities
function M.setup(name, cfg)
    cfg = vim.tbl_deep_extend("force", {
        capabilities = M.capabilities(),
    }, cfg or {})
    vim.lsp.config(name, cfg)
    vim.lsp.enable(name)
end

return M
