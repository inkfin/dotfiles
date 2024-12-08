return {
    {
        "folke/snacks.nvim",
        opts = {
            dashboard = {
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
                    -- stylua: ignore
                    ---@type snacks.dashboard.Item[]
                    keys = {
                        { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
                        { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
                        { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
                        { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
                        { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
                        { icon = " ", key = "s", desc = "Restore Session", section = "session" },
                        { icon = " ", key = "p", desc = "Projects", action = ":Telescope projects" },
                        { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
                        -- { icon = " ", key = "q", desc = "Quit", action = ":qa" },
                    },
                },
            },
        },
    },
    {
        "nvimdev/dashboard-nvim",
        event = "VimEnter",
        enabled = false,
        opts = function(_, opts)
            local logo = [[
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
]]

            logo = "\n\n\n\n" .. logo .. "\n\n"

            if type(opts) == "table" then
                opts.config.header = vim.split(logo, "\n")
                -- stylua: ignore
                opts.config.center = {
                    { action = "Telescope find_files",                                     desc = " Find file",       icon = " ", key = "f" },
                    { action = "ene | startinsert",                                        desc = " New file",        icon = " ", key = "n" },
                    { action = "Telescope oldfiles",                                       desc = " Recent files",    icon = " ", key = "r" },
                    { action = "Telescope live_grep",                                      desc = " Find text",       icon = " ", key = "g" },
                    { action = 'lua require("persistence").load()',                        desc = " Restore Session", icon = " ", key = "s" },
                    { action = "Telescope projects",                                       desc = " Projects",        icon = " ", key = "p" },
                    { action = "Lazy",                                                     desc = " Lazy",            icon = "󰒲 ", key = "l" },
                    { action = "qa",                                                       desc = " Quit",            icon = " ", key = "q" },
                }
            end
        end,
    },
}
