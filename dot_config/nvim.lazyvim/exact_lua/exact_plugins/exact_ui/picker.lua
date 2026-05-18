return {
    {
        "folke/snacks.nvim",
        opts = {
            picker = {
                sources = {
                    files = {
                        exclude = {
                            ".git",
                            ".svn",
                            ".cache",
                            "node_modules",
                            "spell",
                            "elpa",
                        },
                    },
                    grep = {
                        exclude = {
                            ".git",
                            ".svn",
                            ".cache",
                            "node_modules",
                            "spell",
                            "elpa",
                        },
                    },
                },
            },
        },
        keys = {
            {
                "<leader>fz",
                function()
                    Snacks.picker.zoxide()
                end,
                desc = "Zoxide list",
            },
        },
    },
}
