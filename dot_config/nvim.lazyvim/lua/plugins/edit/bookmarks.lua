return {

    -- KEYMAPS:
    --   <https://github.com/chentoast/marks.nvim#mappings>
    --     mx              Set mark x
    --     m,              Set the next available alphabetical (lowercase) mark
    --     m;              Toggle the next available mark at the current line
    --     dmx             Delete mark x
    --     dm-             Delete all marks on the current line
    --     dm<space>       Delete all marks in the current buffer
    --     m]              Move to next mark
    --     m[              Move to previous mark
    --     m:              Preview mark. This will prompt you for a specific mark to
    --                     preview; press <cr> to preview the next mark.
    --
    --     m[0-9]          Add a bookmark from bookmark group[0-9].
    --     dm[0-9]         Delete all bookmarks from bookmark group[0-9].
    --     m}              Move to the next bookmark having the same type as the bookmark under
    --                     the cursor. Works across buffers.
    --     m{              Move to the previous bookmark having the same type as the bookmark under
    --                     the cursor. Works across buffers.
    --     dm=             Delete the bookmark under the cursor.
    {
        "chentoast/marks.nvim",
        version = false,
        lazy = false,
        config = true,
        opts = {
            -- default_mappings = false,
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
                annotate = "m<cr>",
            },
        },
        -- stylua: ignore
        keys = {
            { "<leader>xm",  mode = {"n"}, "<CMD>MarksListBuf<CR>", desc = "Marks: list buf" },
            { "<leader>xM",  mode = {"n"}, "<CMD>MarksListAll<CR>", desc = "Marks: list all" },
            { "<leader>xb",  mode = {"n"}, "<CMD>BookmarksListAll<CR>", desc = "Bookmarks: list" },
        },
    },
}
