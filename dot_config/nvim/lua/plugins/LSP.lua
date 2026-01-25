-- LSP basic configurations,
-- see https://www.lazyvim.org/plugins/lsp#%EF%B8%8F-customizing-lsp-keymaps for more details.

return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
            -- Be aware that you also will need to properly configure your LSP server to
            -- provide the inlay hints.
            inlay_hints = {
                enabled = vim.fn.has("nvim-0.10") == 1,
                exclude = {},
            },
            -- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
            -- Be aware that you also will need to properly configure your LSP server to
            -- provide the code lenses.
            codelens = {
                enabled = false,
                -- enabled = vim.fn.has("nvim-0.10") == 1,
            },
            -- Add a border to the diagnostics window or popup
            -- https://github.com/LazyVim/LazyVim/discussions/2825#discussioncomment-8914135
            diagnostics = {
                float = {
                    border = "rounded",
                },
            },
            servers = {
                ["*"] = {
                    -- lsp keymaps customization
                    keys = {
                        { "K", false },
                        -- cancel <leader>cr from rename
                        { "<leader>cr", false }, -- disable default rename
                        { "<leader>rn", vim.lsp.buf.rename, desc = "Rename" },
                        -- unmap <leader>cl from Lsp Info
                        { "<leader>cl", false }, -- disable default LspInfo
                        { "<leader>uL", function() Snacks.picker.lsp_config() end, desc = "Lsp Info" },
                        -- map <leader>cl
                        { "<leader>cc", false }, -- disable default codelens
                        { "<leader>cl", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "x" }, has = "codeLens" },
                    },
                },
            },
        },
    },
    {
        "chrisgrieser/nvim-lsp-endhints",
        enabled = vim.fn.has("nvim-0.10") == 1 and vim.g.legacy_inlay_hints == true,
        event = "LspAttach",
        opts = {
            label = {
                truncateAtChars = 20,
                padding = 1,
                marginLeft = 0,
                sameKindSeparator = ", ",
            },
            icons = {
                type = "󰜁 ",
                parameter = "󰏪 ",
                offspec = " ", -- hint kind not defined in official LSP spec
                unknown = "",
            },
            autoEnableHints = true,
        },
        keys = {
            -- stylua: ignore
            { "<leader>ul", mode = "n", function() require("lsp-endhints").toggle() end, desc = "toggle endhints" },
        },
    },
    {
        "pechorin/any-jump.vim",
        init = function()
            -- Show line numbers in search results
            vim.g.any_jump_list_numbers = 0

            -- Auto group results by filename
            -- vim.g.any_jump_grouping_enabled = 1

            -- Search references only for current file type
            vim.g.any_jump_references_only_for_current_filetype = 1

            -- Disable search engine ignore vcs untracked files
            vim.g.any_jump_disable_vcs_ignore = 0

            -- Custom ignore files
            vim.g.any_jump_ignored_files = { "*.tmp", "*.temp", "*.log", "*.bak", "*.swp" }
        end,
    },
}
