-- ~/.config/nvim.mini/lua/plugins/grug-far.lua
-- MagicDuck/grug-far.nvim: search & replace across files

local ok, grugfar = pcall(require, "grug-far")
if not ok then return end
grugfar.setup()

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
