-- ~/.config/nvim.mini/lua/plugins/noice.lua
-- noice.nvim: replaces the cmdline, messages, and popupmenu UI
-- Dependencies: nui.nvim (required), nvim-treesitter (for highlighting)
-- Docs: https://github.com/folke/noice.nvim

require("pack").add({
    "https://github.com/folke/noice.nvim",
    "https://github.com/MunifTanjim/nui.nvim",
})

local ok, noice = pcall(require, "noice")
if not ok then return end

noice.setup({
    lsp = {
        -- Override markdown rendering for LSP hover / signature to use
        -- treesitter for highlighting instead of the built-in renderer
        override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"]                = true,
        },
        signature = {
            enabled  = true,
            auto_open = { enabled = true },
        },
    },

    presets = {
        -- Use classic bottom cmdline for / and ? searches (less distracting)
        bottom_search    = true,
        -- Show cmdline and popupmenu together in a centered popup
        command_palette  = true,
        -- Route long messages to a split instead of a tiny popup
        long_message_to_split = true,
    },

    -- Cmdline popup position: centred horizontally, just above the bottom
    views = {
        cmdline_popup = {
            position = { row = -2, col = "50%" },
        },
        cmdline_popupmenu = {
            position = { row = -5, col = "50%" },
        },
    },

    -- Suppress noisy messages
    routes = {
        -- Hide "written" confirmation after :w
        {
            filter = { event = "msg_show", find = "written" },
            opts   = { skip = true },
        },
    },
})

-- Scroll LSP hover / signature docs with <C-d> / <C-u>
-- Falls back to normal <C-d>/<C-u> when not inside a noice doc window
local function scroll(delta)
    return function()
        if not require("noice.lsp").scroll(delta) then
            return delta > 0 and "<C-d>" or "<C-u>"
        end
    end
end

vim.keymap.set({ "i", "n", "s" }, "<C-d>",
    scroll(4),  { silent = true, expr = true, desc = "Scroll docs / page down" })
vim.keymap.set({ "i", "n", "s" }, "<C-u>",
    scroll(-4), { silent = true, expr = true, desc = "Scroll docs / page up" })

-- Browse notification history
vim.keymap.set("n", "<leader>fn",
    "<Cmd>Noice telescope<CR>", { silent = true, desc = "Noice message history" })
