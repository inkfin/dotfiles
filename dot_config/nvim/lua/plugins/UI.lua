---reference: <https://www.lazyvim.org/plugins/ui>

return {
    {
        "tiagovla/scope.nvim",
        lazy = false,
        version = false,
        config = function()
            require("scope").setup({})
            require("telescope").load_extension("scope")

            vim.keymap.del("n", "<leader>sb")
            vim.keymap.set("n", "<leader>sb", "<CMD>Telescope scope buffers<CR>", { desc = "Buffer", silent = true })
        end,
    },
    {
        "akinsho/bufferline.nvim",
        opts = {
            options = {
                always_show_bufferline = true,
            },
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {},
    },
}
