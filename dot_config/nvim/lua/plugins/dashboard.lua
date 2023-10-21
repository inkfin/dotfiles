return {
    {
        "nvimdev/dashboard-nvim",
        event = "VimEnter",
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
