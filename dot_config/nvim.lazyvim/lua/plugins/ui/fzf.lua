return {
    {
        "ibhagwan/fzf-lua",
        opts = {
            files = {
                file_ignore_patterns = {
                    "%.git[/\\]",
                    "%.svn[/\\]",
                    "%.cache[/\\]",
                    "node_modules[/\\]",
                    "spell[/\\]",
                    "elpa[/\\]",
                },
            },
            grep = {
                file_ignore_patterns = {
                    "%.git[/\\]",
                    "%.svn[/\\]",
                    "%.cache[/\\]",
                    "node_modules[/\\]",
                    "spell[/\\]",
                    "elpa[/\\]",
                },
            },
        },
        keys = {
            {
                "<leader>fz",
                function()
                    require("fzf-lua").zoxide()
                end,
                desc = "Zoxide list",
            },
        },
    },
}
