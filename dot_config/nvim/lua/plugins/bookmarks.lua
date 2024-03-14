return {
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
            bookmark_1 = {
                sign = "⚑",
            },
            bookmark_0 = {
                sign = "⚑",
                virt_text = "annotate",
                -- explicitly prompt for a virtual line annotation when setting a bookmark from this group.
                -- defaults to false.
                annotate = true,
            },
            mappings = {
                annotate = "ma",
            },
        },
        -- stylua: ignore
        keys = {
            { "dm",  mode = {"n"}, "<Plug>(Marks-delete)", desc = "delete mark" },
            { "mm",  mode = {"n"}, "<Plug>(Marks-toggle)", desc = "toggle mark" },
            { "mdl", mode = {"n"}, "<Plug>(Marks-deleteline)", desc = "delete mark (line)" },
            { "mdb", mode = {"n"}, "<Plug>(Marks-deletebuf)", desc = "delete mark (buf)" },
            { "m]",  mode = {"n"}, "<Plug>(Marks-next)", desc = "next mark" },
            { "m[",  mode = {"n"}, "<Plug>(Marks-prev)", desc = "prev mark" },
            -- bookmarks
            { "mdd", mode = {"n"}, "<Plug>(Marks-delete-bookmark)", desc = "delete bookmark" },
            { "mn",  mode = {"n"}, "<Plug>(Marks-next-bookmark)", desc = "next bookmark (group)" },
            { "mp",  mode = {"n"}, "<Plug>(Marks-prev-bookmark)", desc = "prev bookmark (group)" },
            { "ma",  mode = {"n"}, "<Plug>(Marks-toggle-bookmark0)", desc = "annotate mark" },

            { "m0",  mode = {"n"}, "<Plug>(Marks-toggle-bookmark0)", desc = "which_key_ignore" },
            { "m1",  mode = {"n"}, "<Plug>(Marks-toggle-bookmark1)", desc = "which_key_ignore" },
            { "m2",  mode = {"n"}, "<Plug>(Marks-toggle-bookmark2)", desc = "which_key_ignore" },
            { "m3",  mode = {"n"}, "<Plug>(Marks-toggle-bookmark3)", desc = "which_key_ignore" },
            { "m4",  mode = {"n"}, "<Plug>(Marks-toggle-bookmark4)", desc = "which_key_ignore" },
            { "m5",  mode = {"n"}, "<Plug>(Marks-toggle-bookmark5)", desc = "which_key_ignore" },
            { "m6",  mode = {"n"}, "<Plug>(Marks-toggle-bookmark6)", desc = "which_key_ignore" },
            { "m7",  mode = {"n"}, "<Plug>(Marks-toggle-bookmark7)", desc = "which_key_ignore" },
            { "m8",  mode = {"n"}, "<Plug>(Marks-toggle-bookmark8)", desc = "which_key_ignore" },
            { "m9",  mode = {"n"}, "<Plug>(Marks-toggle-bookmark9)", desc = "which_key_ignore" },
        },
    },
}
