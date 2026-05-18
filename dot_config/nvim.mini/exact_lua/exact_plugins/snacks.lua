-- ~/.config/nvim.mini/lua/plugins/snacks.lua
-- snacks.nvim: collection of small QoL plugins by folke
-- Docs: https://github.com/folke/snacks.nvim/tree/main/docs

require("pack").add("https://github.com/folke/snacks.nvim")

local ok, snacks = pcall(require, "snacks")
if not ok then return end

local git_picker = {
    layout = {
        preset = "sidebar",
        layout = {
            width = 0.3,
        },
    },
}

snacks.setup({
    -- Gracefully handle large files: disables heavy features (treesitter,
    -- LSP, etc.) when opening files above a size threshold
    bigfile = { enabled = true },

    -- Indent guides + scope highlight
    indent = { enabled = true },

    -- Replaces vim.ui.input with a nicer floating prompt
    input = { enabled = true },

    -- Picker UI, including vim.ui.select used by LSP code actions
    picker = {
        enabled = true,
        ui_select = true,
        layout = {
            preset = "ivy",
            layout = {
                height = 0.6,
            },
        },
        sources = {
            git_files = vim.deepcopy(git_picker),
            git_log = vim.deepcopy(git_picker),
            git_log_file = vim.deepcopy(git_picker),
            git_log_line = vim.deepcopy(git_picker),
            git_status = vim.deepcopy(git_picker),
            git_stash = vim.deepcopy(git_picker),
            git_diff = vim.deepcopy(git_picker),
        },
    },

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
        filter  = function(notif)
            -- blink.cmp v1.10.x race: scheduled show fires after context cleared
            if notif.msg and notif.msg:find("Context must be set before getting selection mode") then
                return false
            end
            return true
        end,
    },

    -- Persistent scratch buffers
    scratch = { enabled = true },

    -- LSP-integrated file rename (used by explorer and <leader>fr keymap)
    rename = { enabled = true },

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

    -- Enabled — used by Snacks.lazygit() and Snacks.terminal(); toggleterm
    -- handles the bottom shell (<C-/>) separately
    terminal  = { enabled = true },
    -- File explorer (sidebar picker)
    explorer  = {
        enabled = true,
    },
    -- Disabled — personal preference
    scroll    = { enabled = false },
    zen       = { enabled = false },
})

local map = vim.keymap.set
map("n", "<leader>.",  function() Snacks.scratch() end,        { desc = "Scratch buffer" })
map("n", "<leader>S",  function() Snacks.scratch.select() end, { desc = "Select scratch" })
map("n", "<leader>fr", function() Snacks.rename.rename_file() end, { desc = "Rename file" })
