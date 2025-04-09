if _G.disable_plugins.org then
    return {}
end

return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            -- add tsx and treesitter
            opts.highlight.enable = true
            vim.list_extend(opts.ensure_installed, { "norg" })
            if opts.highlight.additional_vim_regex_highlighting == nil then
                opts.highlight.additional_vim_regex_highlighting = {}
            end
            vim.list_extend(opts.highlight.additional_vim_regex_highlighting, { "norg" })
        end,
    },
    -- {
    --     "hrsh7th/nvim-cmp",
    --     ---@param opts cmp.ConfigSchema
    --     opts = function(_, opts)
    --         local cmp = require("cmp")
    --         opts.sources = cmp.config.sources(vim.list_extend(opts.sources, { { name = "orgmode" } }))
    --     end,
    -- },
    {
        "nvim-neorg/neorg",
        lazy = false,
        ft = "norg",
        opts = function(_, opts)
            opts.load = {
                ["core.defaults"] = {
                    -- https://github.com/nvim-neorg/neorg/wiki#default-modules
                },
                ["core.todo-introspector"] = {},
                ["core.ui"] = {},
                ["core.ui.calendar"] = {},
                -- https://github.com/nvim-neorg/neorg/wiki/Concealer
                ["core.concealer"] = {
                    icon_preset = "basic",
                    icons = {
                        code_block = {
                            spell_check = false,
                        },
                    },
                },
                ["core.dirman"] = {
                    config = {
                        workspaces = {
                            worknotes = "~/Documents/WorkNotes",
                        },
                    },
                },
            }

            require("which-key").add({
                buffer = true,
                cond = function() return vim.bo.filetype == "norg" end,
                mode = { "n", "v" },
                { "<localleader>t", group = "norg [T]ask" },
                { "<localleader>i", group = "norg [I]nsert" },
                { "<localleader>o", group = "norg [O]pen" },
                { "<localleader>c", group = "norg [C]ode block" },
                { "<localleader>n", group = "norg [N]ew" },
                { "<localleader>l", group = "norg [L]ist" },
            })
        end,
        -- stylua: ignore
        keys = {
            -- <C-Space> was occupied, use combination keys
            { "<localleader>tx", mode = { "n" }, "<Plug>(neorg.qol.todo-items.todo.task-cycle)",      desc = "task-cycle",      ft = "norg" },
            { "<localleader>tX", mode = { "n" }, "<Plug>(neorg.qol.todo-items.todo.task-cycle-reverse)", desc = "task-cycle-reverse", ft = "norg" },
            -- Neorg prefix
            { "<localleader>;",  mode = { "n" }, ":Neorg ",                 desc = "Neorg command",     ft = "norg" },
            -- workspaces
            { "<localleader>or", mode = { "n" }, "<CMD>Neorg return<CR>",   desc = "Norg return",       ft = "norg" },
            { "<localleader>ow", mode = { "n" }, ":Neorg workspace ",       desc = "Norg workspace",    ft = "norg" },
            { "<localleader>oi", mode = { "n" }, "<CMD>Neorg index<CR>",    desc = "Norg index",        ft = "norg" },
        },
    },
}
