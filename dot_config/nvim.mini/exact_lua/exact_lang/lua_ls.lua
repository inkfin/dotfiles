-- ~/.config/nvim.mini/lua/lang/lua_ls.lua
-- Lua LSP configuration
-- Server: lua_ls (lua-language-server)

local lsp = require("lsp_util")

local M = {
    mason_lspconfig = { "lua_ls" },
}

function M.setup()
    lsp.setup("lua_ls", {
        settings = {
            Lua = {
                runtime = {
                    version = "LuaJIT",   -- Neovim uses LuaJIT
                },
                workspace = {
                    checkThirdParty = false,
                    -- Make lua_ls aware of all Neovim runtime files
                    -- (vim.*, require("..."), Neovim API, etc.)
                    library = vim.api.nvim_get_runtime_file("", true),
                },
                diagnostics = {
                    -- Suppress "Undefined global `vim`" for Neovim configs
                    globals = { "vim" },
                    -- Disable noisy style warnings; let stylua handle formatting
                    disable = { "missing-fields" },
                },
                -- Let conform.nvim / stylua handle formatting — don't let
                -- lua_ls reformat on save (avoids double-format conflicts).
                format = {
                    enable = false,
                },
                hint = {
                    -- Inlay hints: show param names, types, array/table indices
                    enable         = true,
                    paramName      = "All",
                    paramType      = true,
                    arrayIndex     = "Disable",   -- noisy for Lua tables
                    setType        = true,
                    semicolon      = "Disable",   -- Lua doesn't need semicolons
                },
                telemetry = {
                    enable = false,
                },
                completion = {
                    callSnippet = "Replace",   -- expand function call snippets
                },
            },
        },
    })
end

return M
