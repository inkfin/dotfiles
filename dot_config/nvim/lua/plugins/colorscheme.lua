return {
    -- -- Turn tokyonight to transparent
    -- {
    --     "folke/tokyonight.nvim",
    --     opts = {
    --         transparent = true,
    --         styles = {
    --             sidebars = "transparent",
    --             floats = "transparent",
    --         },
    --     },
    -- },
    -- { "Mofiqul/dracula.nvim", version = "*" },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "tokyonight",
            -- colorscheme = "dracula",
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        -- config = function()
        --     require("lualine").setup({
        --         options = {
        --             theme = "dracula",
        --         },
        --     })
        -- end,
        opts = function(_, opts)
            if type(opts.sections) == "table" then
                local icons = require("lazyvim.config").icons
                local Util = require("lazyvim.util")
                vim.list_extend(opts.sections, {})
                opts.sections.lualine_x = {
                    -- stylua: ignore
                    {
                        function() return require("noice").api.status.command.get() end,
                        cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
                        color = Util.fg("Statement"),
                    },
                    -- stylua: ignore
                    {
                        function() return require("noice").api.status.mode.get() end,
                        cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
                        color = Util.fg("Constant"),
                    },
                    -- stylua: ignore
                    {
                        function() return "  " .. require("dap").status() end,
                        cond = function () return package.loaded["dap"] and require("dap").status() ~= "" end,
                        color = Util.fg("Debug"),
                    },
                    -- Constantly fetch Github for updates, has network issue
                    -- stylua: ignore
                    { require("lazy.status").updates, cond = require("lazy.status").has_updates, color = Util.fg("Special") },
                    {
                        "diff",
                        symbols = {
                            added = icons.git.added,
                            modified = icons.git.modified,
                            removed = icons.git.removed,
                        },
                    },
                }
            end
        end,
    },
}
