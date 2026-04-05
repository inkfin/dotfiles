-- ~/.config/nvim.mini/lua/plugins/noice.lua
-- noice.nvim: native-look cmdline + LSP hover/signature rendering + notifications
-- Dependencies: nui.nvim (required), nvim-treesitter (for highlighting)
-- Docs: https://github.com/folke/noice.nvim

require("pack").add({
    "https://github.com/folke/noice.nvim",
    "https://github.com/MunifTanjim/nui.nvim",
})

local ok, noice = pcall(require, "noice")
if not ok then return end

noice.setup({
    -- Render cmdline at the native bottom bar instead of a floating popup
    cmdline = {
        view = "cmdline",
    },

    lsp = {
        -- Override markdown rendering for LSP hover / signature to use
        -- treesitter for highlighting instead of the built-in renderer
        override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"]                = true,
        },
        signature = {
            enabled   = true,
            auto_open = { enabled = true },
        },
    },

    presets = {
        -- Use classic bottom cmdline for / and ? searches
        bottom_search         = true,
        -- Route long messages to a split instead of a tiny popup
        long_message_to_split = true,
    },

    -- Suppress noisy messages
    routes = {
        -- Hide "written" confirmation after :w
        {
            filter = { event = "msg_show", find = "written" },
            opts   = { skip = true },
        },
        -- Hide "chezmoi" output when auto apply chezmoi
        {
            filter = { event = "msg_show", find = ":!chezmoi" },
            opts = { skip = true },
        },
        -- Show :!cmd shell output in a split with cursor focus
        {
            filter = { event = "msg_show", kind = { "shell_cmd", "shell_out" } },
            view   = "split",
            opts   = { enter = true, size = "80%" },
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
    scroll(4),  { silent = true, expr = true, desc = "Scroll docs forward" })
vim.keymap.set({ "i", "n", "s" }, "<C-u>",
    scroll(-4), { silent = true, expr = true, desc = "Scroll docs backward" })

-- Redirect cmdline output to a split
vim.keymap.set("c", "<S-Enter>",
    function() require("noice").redirect(vim.fn.getcmdline()) end,
    { desc = "Redirect cmdline" })

-- Noice message management (<leader>sn group)
local map = vim.keymap.set
map("n", "<leader>sna", function() require("noice").cmd("all") end,      { desc = "Noice all" })
map("n", "<leader>snd", function() require("noice").cmd("dismiss") end,  { desc = "Dismiss all" })
map("n", "<leader>snh", function() require("noice").cmd("history") end,  { desc = "Noice history" })
map("n", "<leader>snl", function() require("noice").cmd("last") end,     { desc = "Noice last message" })
map("n", "<leader>snt", function() require("noice").cmd("telescope") end,{ desc = "Noice picker (Telescope)" })

-- which-key group label
local ok_wk, wk = pcall(require, "which-key")
if ok_wk then
    wk.add({ { "<leader>sn", group = "noice" } })
end
