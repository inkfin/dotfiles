-- ~/.config/nvim.mini/lua/lang/go.lua
-- Go LSP configuration
-- Server: gopls

local lsp = require("lsp_util")

local M = {
    mason_lspconfig = { "gopls" },
}

function M.setup()
    lsp.setup("gopls", {
        settings = {
            gopls = {
                gofumpt     = true,
                codelenses  = {
                    gc_details  = false,
                    generate    = true,
                    regenerate_cgo = true,
                    run_govulncheck = true,
                    test        = true,
                    tidy        = true,
                    upgrade_dependency = true,
                    vendor      = true,
                },
                hints = {
                    assignVariableTypes    = true,
                    compositeLiteralFields = true,
                    compositeLiteralTypes  = true,
                    constantValues         = true,
                    functionTypeParameters = true,
                    parameterNames         = true,
                    rangeVariableTypes     = true,
                },
                analyses = {
                    fieldalignment = true,
                    nilness        = true,
                    unusedparams   = true,
                    unusedwrite    = true,
                    useany         = true,
                },
                usePlaceholders = true,
                completeUnimported = true,
                staticcheck = true,
                directoryFilters = {
                    "-.git", "-.vscode", "-.idea",
                    "-node_modules", "-vendor",
                },
            },
        },
    })
end

return M
