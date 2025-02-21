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
}
