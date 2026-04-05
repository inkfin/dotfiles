-- ~/.config/nvim.mini/lua/plugins/snacks.lua
-- snacks.nvim: collection of small QoL plugins by folke
-- Docs: https://github.com/folke/snacks.nvim/tree/main/docs

require("pack").add("https://github.com/folke/snacks.nvim")

local ok, snacks = pcall(require, "snacks")
if not ok then return end

snacks.setup({
    -- Gracefully handle large files: disables heavy features (treesitter,
    -- LSP, etc.) when opening files above a size threshold
    bigfile = { enabled = true },

    -- Indent guides + scope highlight
    indent = { enabled = true },

    -- Replaces vim.ui.input with a nicer floating prompt
    input = { enabled = true },

    -- Renders the file content before plugins finish loading (faster startup
    -- perceived feel when opening a file directly from the CLI)
    quickfile = { enabled = true },

    -- Pretty status column: line numbers, folds, signs in one clean column
    statuscolumn = { enabled = true },

    -- Highlights all LSP references to the word under the cursor and lets
    -- you navigate between them with ]] / [[
    words = { enabled = true },

    -- Pretty vim.notify replacement (replaces nvim-notify)
    notifier = {
        enabled = true,
        timeout = 3500,
        style   = "compact",  -- compact | minimal | fancy
    },

    -- Dashboard shown on startup (no buffers open)
    dashboard = {
        enabled = true,
        preset = {
            header = [[
██╗ ██╗ ████╗  ████╗██╗ ██╗█████╗█████╗
██║ ██║██╔═██╗██╔══╝██║██╔╝██╔══╝██╔═██╗
██████║██████║██║   ████╔╝ ████╗ █████╔╝
██╔═██║██╔═██║██║   ██╔██╗ ██╔═╝ ██╔═██╗
██║ ██║██║ ██║╚████╗██║ ██╗█████╗██║ ██║
╚═╝ ╚═╝╚═╝ ╚═╝ ╚═══╝╚═╝ ╚═╝╚════╝╚═╝ ╚═╝
 🕹️ ██████╗  █████╗ ███╗   ███╗███████╗🎮
 ██╔════╝ ██╔══██╗████╗ ████║██╔════╝
 ██║ ████╗███████║██╔████╔██║█████╗
 ██║  ██╔╝██╔══██║██║╚██╔╝██║██╔══╝
 ╚██████║ ██║  ██║██║ ╚═╝ ██║███████╗
 🎯 ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝🎲
]],
            keys = {
                { icon = "󰍉 ", key = "f", desc = "Find File",    action = ":lua Snacks.dashboard.pick('files')"                                   },
                { icon = "󰈔 ", key = "n", desc = "New File",     action = ":ene | startinsert"                                                    },
                { icon = "󰺮 ", key = "g", desc = "Find Text",    action = ":lua Snacks.dashboard.pick('live_grep')"                               },
                { icon = "󰋚 ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')"                                },
                { icon = "󰒓 ", key = "c", desc = "Config",       action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            },
        },
        sections = {
            { section = "header" },
            { section = "keys",         gap = 1, padding = 1 },
            { section = "recent_files", limit = 5, padding = 1 },
        },
    },

    -- Disabled — we use toggleterm for terminals
    terminal  = { enabled = false },
    -- Disabled — we use neo-tree for file browsing
    explorer  = { enabled = false },
    -- Disabled — personal preference
    scroll    = { enabled = false },
    zen       = { enabled = false },
})
