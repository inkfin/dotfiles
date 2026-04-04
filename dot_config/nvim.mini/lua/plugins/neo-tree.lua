-- ~/.config/nvim.mini/lua/plugins/neo-tree.lua
-- nvim-neo-tree/neo-tree.nvim: file explorer

require("pack").add({
    "https://github.com/MunifTanjim/nui.nvim",
    "https://github.com/nvim-neo-tree/neo-tree.nvim",
    "https://github.com/s1n7ax/nvim-window-picker",
})

local ok, neotree = pcall(require, "neo-tree")
if not ok then return end

-- nvim-window-picker (used for opening files in specific windows)
local ok_wp, window_picker = pcall(require, "window-picker")
if ok_wp then
    window_picker.setup()
end

neotree.setup({
    sources = { "filesystem", "buffers", "git_status", "document_symbols" },

    open_files_do_not_replace_types = { "terminal", "Trouble", "qf", "Outline" },

    source_selector = {
        winbar = true,
        show_scrolled_off_parent_node = true,
        sources = {
            { source = "filesystem",       display_name = "󰉓 File" },
            { source = "buffers",          display_name = "󰈚 Buf"  },
            { source = "git_status",       display_name = "󰊢 Git"  },
            { source = "document_symbols", display_name = " Sym"  },
        },
    },

    filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = false,
        filtered_items = {
            visible        = false,
            hide_dotfiles  = false,
            hide_gitignored = true,
            hide_hidden    = true,
            hide_by_name   = { "node_modules", ".cache", ".git", ".svn" },
            hide_by_pattern = { "*.meta" },
            always_show    = { ".gitignored" },
            never_show     = { ".DS_Store" },
        },
        window = {
            mappings = {
                ["O"] = "system_open",
            },
        },
        commands = {
            system_open = function(state)
                local path = state.tree:get_node():get_id()
                if vim.fn.has("mac") == 1 then
                    vim.fn.jobstart({ "open", path }, { detach = true })
                elseif vim.fn.has("linux") == 1 then
                    vim.fn.jobstart({ "xdg-open", path }, { detach = true })
                elseif vim.fn.has("win32") == 1 then
                    vim.cmd('silent !Invoke-Item "' .. path .. '"')
                end
            end,
        },
    },

    window = {
        mappings = {
            ["<space>"] = "none",
        },
    },

    default_component_configs = {
        indent = {
            with_expanders    = true,
            expander_collapsed = "",
            expander_expanded  = "",
            expander_highlight = "NeoTreeExpander",
        },
    },
})

--------------------------
-- Keymaps
--------------------------
local map = vim.keymap.set

-- Toggle at project root (git root or cwd)
map("n", "<leader>e", function()
    local root = vim.fs.root(0, { ".git", ".svn", "Makefile", "package.json" })
        or vim.uv.cwd()
    require("neo-tree.command").execute({ toggle = true, dir = root })
end, { desc = "Explorer NeoTree (root)" })

-- Toggle at cwd
map("n", "<leader>E", function()
    require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
end, { desc = "Explorer NeoTree (cwd)" })

-- Specialised views
map("n", "<leader>fg", "<cmd>Neotree git_status<cr>",        { desc = "NeoTree Git Status" })
map("n", "<leader>fs", "<cmd>Neotree document_symbols<cr>",  { desc = "NeoTree Symbols" })
