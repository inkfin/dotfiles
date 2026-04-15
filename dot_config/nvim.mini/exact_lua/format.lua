-- ~/.config/nvim.mini/lua/format.lua
-- Shared formatting entrypoint.
--
-- Behavior:
-- - Prefer conform.nvim when it is installed/configured.
-- - Let conform fall back to LSP formatting for languages that already have a
--   formatter-capable server.
-- - Fall back to plain vim.lsp.buf.format() if conform is unavailable.

local M = {}

---@param opts? table
function M.format(opts)
    opts = vim.tbl_extend("force", {
        async = false,
        lsp_format = "fallback",
    }, opts or {})

    local ok_conform, conform = pcall(require, "conform")
    if ok_conform then
        return conform.format(opts)
    end

    return vim.lsp.buf.format({
        async = opts.async,
        bufnr = opts.bufnr,
    })
end

return M
