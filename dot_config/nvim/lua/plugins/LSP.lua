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
        },
        init = function()
            -- lsp keymaps customization

            local keys = require("lazyvim.plugins.lsp.keymaps").get()
            keys[#keys + 1] = { "K", false }
            -- cancel <leader>cr from rename
            keys[#keys + 1] = { "<leader>cr", false } -- disable default rename
            keys[#keys + 1] = { "<leader>rn", vim.lsp.buf.rename, desc = "Rename", mode = { "n" } }
            -- unmap <leader>cl from Lsp Info
            keys[#keys + 1] = { "<leader>cl", false } -- disable default LspInfo
            keys[#keys + 1] = { "<leader>uL", "<Cmd>LspInfo<CR>", desc = "Lsp Info", mode = { "n" } }
            -- map <leader>cl
            keys[#keys + 1] = { "<leader>cc", false, mode = { "n", "v" } } -- disable default codelens
            keys[#keys + 1] = { "<leader>cl", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "v" } }
        end,
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
    -- {
    --     "felpafel/inlay-hint.nvim",
    --     enabled = vim.fn.has("nvim-0.10") == 1 and vim.g.legacy_inlay_hints == true,
    --     event = "LspAttach",
    --     opts = {
    --         -- Position of virtual text. Possible values:
    --         -- 'eol': right after eol character (default).
    --         -- 'right_align': display right aligned in the window.
    --         -- 'inline': display at the specified column, and shift the buffer
    --         -- text to the right as needed.
    --         virt_text_pos = "eol",
    --     },
    -- },
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
