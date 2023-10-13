return {
    -- { "folke/neoconf.nvim", cmd = "Neoconf" },
    -- "folke/neodev.nvim",
    {
        "chentoast/marks.nvim",
        version = false,
        lazy = false,
        config = true,
        opts = {
            force_write_shada = false,
        },
        -- stylua: ignore
        -- keys = {
        --     { "m]", mode = {"n"}, "<Plug>(Marks-next-bookmark)", desc = "next bookmark" },
        --     { "m[", mode = {"n"}, "<Plug>(Marks-prev-bookmark)", desc = "prev bookmark" },
        -- },
    },
}
