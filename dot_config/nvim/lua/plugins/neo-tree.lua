return {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
        "s1n7ax/nvim-window-picker",
        name = "window-picker",
        event = "VeryLazy",
        version = "2.*",
        config = function()
            require("window-picker").setup()
        end,
    },
    keys = {
        {
            "<leader>e",
            function()
                local path = require("lazyvim.util").root()
                --[[
                if vim.fn.has("win32") == 1 then
                    -- use \ instead of / in windows
                    path = path:gsub("/", "\\")
                end
                --]]
                require("neo-tree.command").execute({ toggle = true, dir = path })
            end,
            desc = "Explorer NeoTree (root dir)",
        },
        {
            "<leader>E",
            function()
                require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
            end,
            desc = "Explorer NeoTree (cwd)",
        },
        { "<leader>fe", false },
        { "<leader>fE", false },
        { "<leader>fg", "<Cmd>Neotree git_status<CR>", desc = "NeoTree git status" },
        { "<leader>fs", "<Cmd>Neotree document_symbols<CR>", desc = "NeoTree document symbols" },
    },
    opts = {
        sources = { "filesystem", "buffers", "git_status", "document_symbols" },
        open_files_do_not_replace_types = { "terminal", "Trouble", "qf", "Outline" },
        source_selector = {
            winbar = true, -- toggle to show selector on winbar
            show_scrolled_off_parent_node = true,
            sources = {
                { source = "filesystem", display_name = "󰉓 File" },
                { source = "buffers", display_name = "󰈚 Buf" },
                { source = "git_status", display_name = "󰊢 Git" },
                { source = "document_symbols", display_name = " Sym" },
            },
        },
        filesystem = {
            filtered_items = {
                visible = false, -- when true, they will just be displayed differently than normal items
                hide_dotfiles = false,
                hide_gitignored = true,
                hide_hidden = true, -- only works on Windows for hidden files/directories
                hide_by_name = {
                    "node_modules",
                },
                hide_by_pattern = { -- uses glob style patterns
                    "*.meta",
                },
                always_show = { -- remains visible even if other settings would normally hide it
                    ".gitignored",
                },
                never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
                    ".DS_Store",
                    --"thumbs.db"
                },
                never_show_by_pattern = { -- uses glob style patterns
                    --".null-ls_*",
                },
            },
            bind_to_cwd = false,
            follow_current_file = { enabled = true },
            use_libuv_file_watcher = false,

            window = {
                mappings = {
                    ["O"] = "system_open",
                },
            },
            commands = {
                system_open = function(state)
                    local node = state.tree:get_node()
                    local path = '"' .. node:get_id() .. '"'
                    if vim.fn.has("mac") == 1 then
                        vim.fn.jobstart({ "open", path }, { detach = true })
                    elseif vim.fn.has("linux") == 1 then
                        vim.fn.jobstart({ "xdg-open", path }, { detach = true })
                    elseif vim.fn.has("win32") == 1 then
                        vim.cmd("silent !Invoke-Item " .. path)
                    end

                    -- -- Windows: Without removing the file from the path, it opens in code.exe instead of explorer.exe
                    -- local p
                    -- local lastSlashIndex = path:match("^.+()\\[^\\]*$") -- Match the last slash and everything before it
                    -- if lastSlashIndex then
                    --     p = path:sub(1, lastSlashIndex - 1) -- Extract substring before the last slash
                    -- else
                    --     p = path -- If no slash found, return original path
                    -- end
                    -- vim.cmd("silent !start explorer " .. p)
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
                with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
                expander_collapsed = "",
                expander_expanded = "",
                expander_highlight = "NeoTreeExpander",
            },
        },
        event_handlers = {
            {
                event = "file_opened",
                handler = function(file_path)
                    -- auto close
                    -- require("neo-tree.command").execute({ action = "close" })
                end,
            },
        },
    },
}
