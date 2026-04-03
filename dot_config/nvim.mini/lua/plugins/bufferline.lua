-- ~/.config/nvim.mini/lua/plugins/bufferline.lua
-- Buffer tab bar via bufferline.nvim

local ok, bufferline = pcall(require, "bufferline")
if not ok then return end

bufferline.setup({
    options = {
        mode            = "buffers",
        themable        = true,
        numbers         = "none",
        close_command   = "bdelete! %d",
        indicator       = { style = "icon", icon = "▎" },
        buffer_close_icon = "󰅖",
        modified_icon   = "●",
        close_icon      = "",
        left_trunc_marker  = "",
        right_trunc_marker = "",
        diagnostics     = "nvim_lsp",
        diagnostics_indicator = function(_, _, diag)
            local s = ""
            if diag.error   then s = s .. " " .. diag.error   end
            if diag.warning then s = s .. " " .. diag.warning end
            return s
        end,
        offsets = {
            {
                filetype   = "neo-tree",
                text       = "File Explorer",
                text_align = "center",
                separator  = true,
            },
        },
        use_mini_icons          = true,
        show_buffer_close_icons = true,
        show_close_icon         = false,
        show_tab_indicators     = true,
        persist_buffer_sort     = true,
        separator_style         = "thin",
        enforce_regular_tabs    = false,
        always_show_bufferline  = true,
        hover = { enabled = true, delay = 200, reveal = { "close" } },
    },
})

-- keymaps
local map = function(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
end

map("<S-h>",  "<cmd>BufferLineCyclePrev<cr>",     "Prev buffer")
map("<S-l>",  "<cmd>BufferLineCycleNext<cr>",     "Next buffer")
map("[b",     "<cmd>BufferLineCyclePrev<cr>",     "Prev buffer")
map("]b",     "<cmd>BufferLineCycleNext<cr>",     "Next buffer")
map("[B",     "<cmd>BufferLineMovePrev<cr>",      "Move buffer left")
map("]B",     "<cmd>BufferLineMoveNext<cr>",      "Move buffer right")
map("<leader>bp", "<cmd>BufferLinePick<cr>",      "Pick buffer")
map("<leader>bP", "<cmd>BufferLinePickClose<cr>", "Pick buffer to close")
map("<leader>bd", "<cmd>bdelete<cr>",             "Delete buffer")
