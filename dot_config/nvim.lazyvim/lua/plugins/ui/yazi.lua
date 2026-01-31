return {
    {
        "mikavilpas/yazi.nvim",
        keys = {
            {
                "<space>yy",
                "<cmd>Yazi<cr>",
                desc = "Open yazi (Directory of Current File)",
                mode = { "n", "v" },
            },
        },
        opts = {
            integrations = {
                grep_in_directory = function(dir)
                    Snacks.picker.grep({ dirs = { dir } })
                end,
                grep_in_selected_files = function(_, dirs)
                    Snacks.picker.grep({ dirs = dirs })
                end,
            },
        },
    },
}
