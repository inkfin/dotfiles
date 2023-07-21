-- LSP basic configurations,
-- see https://www.lazyvim.org/plugins/lsp#%EF%B8%8F-customizing-lsp-keymaps for more details.

return {
    {
        "neovim/nvim-lspconfig",
        init = function()
            -- lsp keymaps customization

            local keys = require("lazyvim.plugins.lsp.keymaps").get()
            -- cancel K from hover
            keys[#keys + 1] = { "K", false }
            -- cancel <leader>cr from rename
            keys[#keys + 1] = { "<leader>cr", false }
            keys[#keys + 1] = { "<leader>rn", vim.lsp.buf.rename, desc = "rename", mode = { "n" } }
            -- unmap <leader>cl from Lsp Info
            keys[#keys + 1] = { "<leader>cl", false }
            keys[#keys + 1] = { "<leader>uL", "<Cmd>LspInfo<CR>", desc = "Lsp Info", mode = { "n" } }
            -- map <leader>cl
            keys[#keys + 1] = { "<leader>cl", vim.lsp.codelens.run, desc = "codelens", mode = { "n" } }
        end,
    },
}
