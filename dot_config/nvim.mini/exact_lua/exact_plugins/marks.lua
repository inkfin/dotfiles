-- ~/.config/nvim.mini/lua/plugins/marks.lua
-- Enhanced UI for Vim marks and bookmark groups.
--
-- Important: persistence still comes from Neovim's ShaDa support in
-- lua/options.lua. marks.nvim improves visibility, motions, and list commands;
-- it does not replace the underlying persistent mark mechanism.

require("pack").add("https://github.com/chentoast/marks.nvim")

local ok, marks = pcall(require, "marks")
if not ok then return end

marks.setup({
    default_mappings = false,
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
        -- Prompt for a virtual line annotation when using bookmark group 0.
        annotate = true,
    },
    mappings = {
        annotate = "m<cr>",
    },
})

local function map(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
end

local ok_wk, wk = pcall(require, "which-key")
if ok_wk then
    wk.add({
        { "<leader>m",  group = "+bookmarks" },
        { "dm",         group = "+delete marks" },
        { "dm-",        desc = "Delete Marks on Line" },
        { "dm ",        desc = "Delete Marks in Buffer" },
        { "dm=",        desc = "Delete Bookmark Under Cursor" },
        { "dm0",        desc = "Delete Bookmark Group 0" },
        { "dm1",        desc = "Delete Bookmark Group 1" },
    })
end

-- Keep the mark picker on <leader>mm. marks.nvim adds richer mark/bookmark
-- management and grouped bookmark navigation around the same persistent mark
-- model, but uses explicit <leader> mappings here so nothing depends on
-- quickly typing built-in m/dm prefixes.
map("<leader>ma", "<Plug>(Marks-annotate)", "Annotate Bookmark")
map("<leader>mb", "<cmd>BookmarksListAll<cr>", "Bookmarks List")
map("<leader>m0", "<Plug>(Marks-toggle-bookmark0)", "Toggle Bookmark 0")
map("<leader>m1", "<Plug>(Marks-toggle-bookmark1)", "Toggle Bookmark 1")
map("<leader>m]", "<Plug>(Marks-next-bookmark)", "Next Bookmark")
map("<leader>m[", "<Plug>(Marks-prev-bookmark)", "Prev Bookmark")
map("<leader>ml", "<cmd>MarksListBuf<cr>", "Marks List (Buffer)")
map("<leader>mL", "<cmd>MarksListAll<cr>", "Marks List (All)")
map("dm", "<Plug>(Marks-delete)", "Delete Letter Mark")
map("dm-", "<Plug>(Marks-deleteline)", "Delete Marks on Line")
map("dm ", "<Plug>(Marks-deletebuf)", "Delete Marks in Buffer")
map("dm=", "<Plug>(Marks-delete-bookmark)", "Delete Bookmark Under Cursor")
map("dm0", "<Plug>(Marks-delete-bookmark0)", "Delete Bookmark Group 0")
map("dm1", "<Plug>(Marks-delete-bookmark1)", "Delete Bookmark Group 1")
