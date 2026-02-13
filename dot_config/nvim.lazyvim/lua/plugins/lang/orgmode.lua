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
    {
        "hrsh7th/nvim-cmp",
        ---@param opts cmp.ConfigSchema
        opts = function(_, opts)
            local cmp = require("cmp")
            opts.sources = cmp.config.sources(vim.list_extend(opts.sources, { { name = "neorg" } }))
        end,
    },
    {
        "nvim-neorg/neorg",
        version = "*",
        lazy = false,
        ft = "norg",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-neorg/lua-utils.nvim",
            "nvim-neorg/tree-sitter-norg",
        },
        -- treesitter fix <https://github.com/nvim-neorg/neorg/issues/1715#issuecomment-3524433687>
        build = function()
            -- run command manually
            -- ln -sf ~/.local/share/nvim/lazy-rocks/tree-sitter-norg/lib/lua/5.1/parser/norg.so ~/.local/share/nvim/site/parser/norg.so
        end,
        opts = function(_, opts)
            opts.load = {
                -- editing
                -- https://github.com/nvim-neorg/neorg/wiki#default-modules
                ["core.defaults"] = {},
                -- https://github.com/nvim-neorg/neorg/wiki/Concealer
                ["core.concealer"] = {
                    config = {
                        icon_preset = "basic",
                        icons = {
                            code_block = {
                                spell_check = false,
                            },
                        },
                    },
                },
                ["core.summary"] = {},
                ["core.dirman"] = {
                    config = {
                        workspaces = {
                            homenotes = "~/Notes/HomeNotes",
                            worknotes = "~/Notes/WorkNotes",
                            studynotes = "~/Notes/StudyNotes",
                        },
                    },
                },
                -- completion
                ["core.completion"] = {
                    config = {
                        engine = "nvim-cmp",
                    },
                },
                -- exporting
                ["core.export"] = {
                    config = {
                        export_dir = "dist",
                    },
                },
                ["core.export.markdown"] = {
                    config = {
                        extensions = "all",
                    },
                },
                -- cool features
            }

            if vim.g.support_image then
                opts.load["core.latex.renderer"] = {
                    config = {
                        render_on_enter = true,
                    },
                }
            end

            -- treesitter fix <https://github.com/nvim-neorg/neorg/issues/1715#issuecomment-3367507386>
            -- vim.api.nvim_create_autocmd("FileType", {
            --     pattern = { "norg" },
            --     callback = function()
            --         if pcall(vim.treesitter.start) then
            --             vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            --             vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            --         end
            --     end,
            -- })

            vim.api.nvim_create_autocmd({ "FileType" }, {
                pattern = { "norg" },
                callback = function()
                    require("which-key").add({
                        buffer = true,
                        mode = { "n", "v" },
                        { "<localleader>t", group = "norg [T]ask" },
                        { "<localleader>i", group = "norg [I]nsert" },
                        { "<localleader>o", group = "norg [O]pen" },
                        { "<localleader>c", group = "norg [C]ode block" },
                        { "<localleader>n", group = "norg [N]ew" },
                        { "<localleader>l", group = "norg [L]ist" },
                    })
                end,
            })
        end,
        -- stylua: ignore
        keys = {
            -- <C-Space> was occupied, use combination keys
            { "<localleader>tx", mode = { "n" }, "<Plug>(neorg.qol.todo-items.todo.task-cycle)",         desc = "task-cycle",         ft = "norg" },
            { "<localleader>tX", mode = { "n" }, "<Plug>(neorg.qol.todo-items.todo.task-cycle-reverse)", desc = "task-cycle-reverse", ft = "norg" },
            -- Neorg prefix
            { "<localleader>;",  mode = { "n" }, ":Neorg ",                 desc = "Neorg command",     ft = "norg" },
            -- workspaces
            { "<leader>on",      mode = { "n" }, "<CMD>Neorg workspace homenotes<CR>", desc = "Norg worknotes"},
            { "<localleader>or", mode = { "n" }, "<CMD>Neorg return<CR>",   desc = "Norg return",       ft = "norg" },
            { "<localleader>ow", mode = { "n" }, ":Neorg workspace ",       desc = "Norg workspace",    ft = "norg" },
            { "<localleader>oi", mode = { "n" }, "<CMD>Neorg index<CR>",    desc = "Norg index",        ft = "norg" },

            -- meta-data
            { "<localleader>im", mode = { "n" }, "<CMD>Neorg inject-metadata<CR>",     desc = "Inject Metadata", ft = "norg" },
            -- summary
            { "<localleader>is", mode = { "n" }, ":Neorg generate-workspace-summary ", desc = "Generate workspace summary", ft = "norg" },

        },
    },
}

-- vim: set ft=lua:
