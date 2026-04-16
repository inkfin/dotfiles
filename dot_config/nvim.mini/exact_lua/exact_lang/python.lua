-- ~/.config/nvim.mini/lua/lang/python.lua
-- Python LSP configuration
-- Servers: basedpyright (type checking) + ruff (linting / formatting)
-- Strategy: two servers, complementary roles — ruff defers hover to pyright.

local lsp = require("lsp_util")

local M = {
    mason_lspconfig = { "basedpyright", "ruff" },
}

function M.setup()
    --------------------------
    -- basedpyright
    -- Role: type checking, go-to-definition, hover, completions
    --------------------------
    lsp.setup("basedpyright", {
        settings = {
            basedpyright = {
                analysis = {
                    typeCheckingMode     = "standard",   -- off < basic < standard < strict
                    diagnosticMode       = "workspace",  -- analyse whole project, not just open files
                    autoSearchPaths      = true,
                    useLibraryCodeForTypes = true,
                    -- Defer diagnostics that ruff already covers to avoid duplication
                    ignore = { "*" },                    -- suppress basedpyright's own lint rules;
                                                         -- ruff is the linter, pyright is the type checker
                },
            },
            python = {
                -- Automatically detect virtualenvs created by poetry, venv, etc.
                venvPath = ".",
                pythonPath = (function()
                    -- prefer .venv/bin/python in the project root if it exists
                    local venv = vim.fn.getcwd() .. "/.venv/bin/python"
                    return vim.fn.executable(venv) == 1 and venv or vim.fn.exepath("python3")
                end)(),
            },
        },
    })

    --------------------------
    -- ruff
    -- Role: linting, import sorting, code fixes — NOT hover (pyright owns that)
    --------------------------
    lsp.setup("ruff", {
        init_options = {
            settings = {
                -- Surface only errors/warnings, suppress info-level noise
                logLevel      = "error",
                lineLength    = 100,
                fixAll        = true,   -- enable auto-fix on format
                organizeImports = true,
            },
        },
        on_attach = function(client, _)
            -- Disable hover: basedpyright provides richer hover docs
            client.server_capabilities.hoverProvider = false
        end,
    })
end

return M
