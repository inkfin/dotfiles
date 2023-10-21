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
    {
        "folke/todo-comments.nvim",
        -- stylua: ignore
        keys = {
            { "]t", false },
            { "[t", false },
            { "]T", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
            { "[T", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
            { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todo (Trouble)" },
            { "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
            { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
            { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
        },
    },
}
