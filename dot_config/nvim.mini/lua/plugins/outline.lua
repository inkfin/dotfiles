-- ~/.config/nvim.mini/lua/plugins/outline.lua
-- hedyhli/outline.nvim: symbol outline panel

require("pack").add("https://github.com/hedyhli/outline.nvim")

local ok, outline = pcall(require, "outline")
if not ok then return end

outline.setup({
    outline_window = {
        position        = "right",
        width           = 30,
        relative_width  = false,
        auto_close      = false,
        auto_jump       = false,
        show_numbers    = false,
        show_relative_numbers = false,
        wrap            = false,
    },
    outline_items = {
        show_symbol_details  = true,
        show_symbol_lineno   = false,
        highlight_hovered_item = true,
        auto_set_cursor      = true,
    },
    symbol_folding = {
        autofold_depth    = 1,
        auto_unfold_hover = true,
    },
    preview_window = {
        auto_preview   = false,
        open_hover_on_preview = false,
    },
})

vim.keymap.set("n", "<leader>oo", "<cmd>Outline<cr>",
    { silent = true, desc = "Toggle Outline" })
