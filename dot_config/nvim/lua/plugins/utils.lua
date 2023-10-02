return {
    -- { "folke/neoconf.nvim", cmd = "Neoconf" },
    -- "folke/neodev.nvim",
    {
        "goolord/alpha-nvim",
        opts = function()
            local dashboard = require("alpha.themes.dashboard")
            --       local logo = [[
            --      ██╗      █████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗          Z
            --      ██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██║   ██║██║████╗ ████║      Z
            --      ██║     ███████║  ███╔╝  ╚████╔╝ ██║   ██║██║██╔████╔██║   z
            --      ██║     ██╔══██║ ███╔╝    ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ z
            --      ███████╗██║  ██║███████╗   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║
            --      ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝
            -- ]]
            local logo = [[
                   千里之行,始于足下                      
      ]]
            dashboard.section.header.val = vim.split(logo, "\n")
        end,
    },
    {
        "chentoast/marks.nvim",
        version = false,
        lazy = false,
        config = true,
        opts = {
            force_write_shada = false,
        },
        -- stylua: ignore
        -- keys = {
        --     { "m]", mode = {"n"}, "<Plug>(Marks-next-bookmark)", desc = "next bookmark" },
        --     { "m[", mode = {"n"}, "<Plug>(Marks-prev-bookmark)", desc = "prev bookmark" },
        -- },
    },
}
