---reference: <https://www.lazyvim.org/plugins/ui>

return {
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
