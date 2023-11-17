return {
    -- { "folke/neoconf.nvim", cmd = "Neoconf" },
    -- "folke/neodev.nvim",
    {
        "chentoast/marks.nvim",
        -- https://github.com/chentoast/marks.nvim#mappings
        version = false,
        lazy = false,
        config = true,
        opts = {
            default_mappings = false,
            -- builtin_marks = { ".", "<", ">", "^" },
            cyclic = true,
            force_write_shada = false,
            refresh_interval = 250,
            excluded_filetypes = {},
        },
        -- stylua: ignore
        keys = {
            { "dm",  mode = {"n"}, "<Plug>(Marks-delete)", desc = "delete mark" },
            { "mm",  mode = {"n"}, "<Plug>(Marks-toggle)", desc = "toggle bookmark" },
            { "mdd", mode = {"n"}, "<Plug>(Marks-delete-bookmark)", desc = "delete bookmark" },
            { "mdl", mode = {"n"}, "<Plug>(Marks-deleteline)", desc = "delete mark (line)" },
            { "mdb", mode = {"n"}, "<Plug>(Marks-deletebuf)", desc = "delete mark (buf)" },
            { "mn",  mode = {"n"}, "<Plug>(Marks-next-bookmark)", desc = "next bookmark (group)" },
            { "mp",  mode = {"n"}, "<Plug>(Marks-prev-bookmark)", desc = "prev bookmark (group)" },
            { "m]",  mode = {"n"}, "<Plug>(Marks-next)", desc = "next bookmark" },
            { "m[",  mode = {"n"}, "<Plug>(Marks-prev)", desc = "prev bookmark" },
        },
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
