return {
    {
        "nvim-telescope/telescope.nvim",
        opts = {
            defaults = {
                layout_strategy = "flex", -- default horizontal
                layout_config = {
                    horizontal = {
                        preview_cutoff = 80,
                    },
                    vertical = {
                        preview_cutoff = 80,
                    },
                },
                file_ignore_patterns = {
                    ".git",
                    ".svn",
                    ".cache",
                    "node_modules",
                    "spell", -- nvim dictionaries
                    "elpa", -- emacs packages
                },
            },
        },
    },
    {
        "jvgrootveld/telescope-zoxide",
        keys = {
            {
                "<leader>fz",
                function()
                    require("telescope").extensions.zoxide.list()
                end,
                desc = "Zoxide list",
            },
        },
        config = function()
            require("telescope").load_extension("zoxide")
        end,
    },
}
