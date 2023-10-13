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
                if vim.fn.has("win32") then
                    -- use \ instead of / in windows
                    path = path:gsub("/", "\\")
                end
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
            bind_to_cwd = false,
            follow_current_file = { enabled = true },
            use_libuv_file_watcher = true,
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
    },
    config = function(_, opts)
        require("neo-tree").setup(opts)
        vim.api.nvim_create_autocmd("TermClose", {
            pattern = "*lazygit",
            callback = function()
                if package.loaded["neo-tree.sources.git_status"] then
                    require("neo-tree.sources.git_status").refresh()
                end
            end,
        })
    end,
}
