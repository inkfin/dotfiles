return {
    {
        "nvimdev/dashboard-nvim",
        event = "VimEnter",
        opts = {
            config = {
                -- header = "",
                -- stylua: ignore
                center = {
                { action = "Telescope find_files",                                     desc = " Find file",       icon = " ", key = "f" },
                { action = "ene | startinsert",                                        desc = " New file",        icon = " ", key = "n" },
                { action = "Telescope oldfiles",                                       desc = " Recent files",    icon = " ", key = "r" },
                { action = "Telescope live_grep",                                      desc = " Find text",       icon = " ", key = "g" },
                { action = 'lua require("persistence").load()',                        desc = " Restore Session", icon = " ", key = "s" },
                { action = "Telescope projects",                                       desc = " Projects",        icon = " ", key = "p" },
                { action = "Lazy",                                                     desc = " Lazy",            icon = "󰒲 ", key = "l" },
                { action = "qa",                                                       desc = " Quit",            icon = " ", key = "q" },
        },
            },
        },
    },
}
