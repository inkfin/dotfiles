-- stylua: ignore
if true then return {} end

return {
    -- Install code highlighter
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            if type(opts.ensure_installed) == "table" then
                vim.list_extend(opts.ensure_installed, {
                    "go",
                    "gomod",
                    "gowork",
                    "gosum",
                })
            end
        end,
    },
    -- Install lsp and dap
    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            if type(opts.ensure_installed) == "table" then
                vim.list_extend(opts.ensure_installed, {
                    "gopls", --lsp
                    "delve", --dap
                    "gofumpt", --formatter
                    "goimports-reviser",
                    "gomodifytags",
                })
            end
        end,
    },

    -- Correctly setup lspconfig for go 🚀
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                gopls = {
                    settings = {
                        gopls = {
                            gofumpt = true,
                            codelenses = {
                                gc_details = false,
                                generate = true,
                                regenerate_cgo = true,
                                run_govulncheck = true,
                                test = true,
                                tidy = true,
                                upgrade_dependency = true,
                                vendor = true,
                            },
                            hints = {
                                assignVariableTypes = true,
                                compositeLiteralFields = true,
                                compositeLiteralTypes = true,
                                constantValues = true,
                                functionTypeParameters = true,
                                parameterNames = true,
                                rangeVariableTypes = true,
                            },
                            analyses = {
                                fieldalignment = true,
                                nilness = true,
                                unusedparams = true,
                                unusedwrite = true,
                                useany = true,
                            },
                            usePlaceholders = true,
                            completeUnimported = true,
                            staticcheck = true,
                            directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
                            semanticTokens = true,
                        },
                    },
                },
            },
        },
    },

    -- formatter config
    -- {
    --     "nvimtools/none-ls.nvim",
    --     opts = function(_, opts)
    --         if type(opts.sources) == "table" then
    --             local nls = require("null-ls")
    --             vim.list_extend(opts.sources, {
    --                 nls.builtins.code_actions.gomodifytags,
    --                 nls.builtins.code_actions.impl,
    --                 nls.builtins.formatting.gofumpt,
    --                 nls.builtins.formatting.goimports_reviser,
    --             })
    --         end
    --     end,
    -- },
}
