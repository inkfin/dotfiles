-- ~/.config/nvim.mini/lua/plugins/grug-far.lua
-- MagicDuck/grug-far.nvim: search & replace across files

require("pack").add("https://github.com/MagicDuck/grug-far.nvim")

local ok, grugfar = pcall(require, "grug-far")
if not ok then return end
grugfar.setup({
    openTargetWindow = {
        -- Reuse the window that was active before opening grug-far.
        -- This is more reliable than geometric "left/right" detection when
        -- navigating matches from the grug-far split.
        preferredLocation = "prev",
    },
})

local map = vim.keymap.set

-- Normal mode: pre-fill search with the word under cursor, operate within buffer
map("n", "<leader>sr", function()
    require("grug-far").open({
        prefills = { search = vim.fn.expand("<cword>") },
        visualSelectionUsage = "operate-within-range",
    })
end, { desc = "Search & Replace (buffer, cword)" })

-- Visual mode: operate within visual selection range
map({ "x", "v" }, "<leader>sr", function()
    require("grug-far").open({
        visualSelectionUsage = "operate-within-range",
    })
end, { desc = "Search & Replace (selection)" })

-- Global search & replace (no prefills, no range restriction)
map({ "n", "x" }, "<leader>sR", function()
    require("grug-far").open()
end, { desc = "Search & Replace (global)" })
