-- ~/.config/nvim.mini/lua/plugins/undotree.lua
-- mbbill/undotree: visual undo history tree

vim.g.undotree_WindowLayout = 3

-- Enable diff panel only if the system diff binary is available
vim.g.undotree_DiffAutoOpen = (vim.fn.executable("diff") == 1) and 1 or 0

vim.keymap.set("n", "U", function()
    vim.cmd.UndotreeToggle()
    vim.cmd.UndotreeFocus()
end, { noremap = true, silent = true, desc = "Toggle undotree" })
