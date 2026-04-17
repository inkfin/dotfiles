-- ~/.config/nvim.mini/lua/plugins/explorer.lua
-- File exploration: Snacks.explorer (sidebar) + oil.nvim (buffer editing)

local cfg = require("config")

--------------------------
-- Snacks Explorer
--------------------------
-- Enabled via snacks.lua (explorer = { enabled = true, replace_netrw = true })
-- Rename/move inside the explorer automatically calls Snacks.rename.rename_file(),
-- which sends LSP workspace/willRenameFiles + workspace/didRenameFiles.

local map = vim.keymap.set

map("n", "<leader>e", function()
    Snacks.explorer({ cwd = cfg.project_root(0) })
end, { desc = "Explorer (root)" })

map("n", "<leader>E", function()
    Snacks.explorer({ cwd = vim.uv.cwd() })
end, { desc = "Explorer (cwd)" })

--------------------------
-- oil.nvim
--------------------------
require("pack").add("https://github.com/stevearc/oil.nvim")

local ok, oil = pcall(require, "oil")
if not ok then return end

oil.setup({
    -- oil owns netrw: opening a directory (nvim ., vim -, netrw) shows oil
    default_file_explorer = true,

    columns = { "icon" },

    skip_confirm_for_simple_edits = true,

    view_options = {
        show_hidden     = false,   -- toggle with g.
        hide_gitignored = true,
    },

    float = {
        padding = 2,
        border  = "rounded",
    },

    -- Notify LSP on rename/move
    lsp_file_methods = {
        enabled          = true,
        timeout_ms       = 1000,
        autosave_changes = false,
    },
})

-- Float: edit the parent dir of the current file
map("n", "<leader>o", function() oil.toggle_float() end,
    { desc = "Oil float (parent dir)" })

-- vim-vinegar style: open parent dir in split
map("n", "-", "<CMD>Oil<CR>",
    { desc = "Oil (parent dir)" })
