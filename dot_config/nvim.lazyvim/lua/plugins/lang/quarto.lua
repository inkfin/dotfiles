--- Quarto nivm configuration
--- https://github.com/jmbuhr/quarto-nvim-kickstarter/blob/main/lua/plugins/quarto.lua
--- https://github.com/jmbuhr/lazyvim-starter-for-quarto/blob/main/lua/plugins/quarto.lua

if _G.disable_plugins.quarto then
    return {}
end

return {

    -- this taps into vim.ui.select and vim.ui.input
    -- and in doing so currently breaks renaming in otter.nvim
    { "stevearc/dressing.nvim", enabled = vim.bo.filetype ~= "quarto" },

    {
        "quarto-dev/quarto-nvim",
        ft = { "quarto", "markdown" },
        enabled = not vim.wo.diff,
        dependencies = {
            "jmbuhr/otter.nvim",
            enabled = not vim.wo.diff,
            opts = {
                buffers = {
                    set_filetype = true,
                },
            },
        },
        config = function()
            require("quarto").setup({
                lspFeatures = {
                    languages = { "python", "bash", "html", "lua" },
                },
                -- Code runner setup in notebook.lua
                codeRunner = {
                    enabled = vim.fn.has("mac") == 1, -- only on mac for now
                    default_method = "molten",
                },
                keymap = {
                    hover = "K",
                    definition = "gd",
                    type_definition = "gD",
                    rename = "<leader>rn",
                    format = "<leader>fm",
                    references = "gr",
                },
            })

            require("which-key").add({
                buffer = true,
                mode = { "n", "v" },
                { "<localleader>q", group = "quarto" },
                { "<localleader>r", group = "run" },
            })
        end,
        -- stylua: ignore
        keys = {

            { "<localleader>qa", "<cmd>QuartoActivate<cr>",         desc = "Quarto Activate",   ft = "quarto", silent = true },
            { "<localleader>qp", "<cmd>QuartoPreview<cr>",          desc = "Preview",           ft = "quarto", silent = true },
            { "<localleader>qq", "<cmd>QuartoClosePreview<cr>",     desc = "quit Preview",      ft = "quarto", silent = true },

            { "<localleader>rc", function() require("quarto.runner").run_cell() end,       desc = "run cell",            ft = "quarto", silent = true },
            { "<localleader>ra", function() require("quarto.runner").run_above() end,      desc = "run cell and above",  ft = "quarto", silent = true },
            { "<localleader>rA", function() require("quarto.runner").run_all() end,        desc = "run all cells",       ft = "quarto", silent = true },
            { "<localleader>rl", function() require("quarto.runner").run_line() end,       desc = "run line",            ft = "quarto", silent = true },
            { "<localleader>r",  function() require("quarto.runner").run_range() end, mode = "v", desc = "run visual range", ft = "quarto", silent = true },
            { "<localleader>RA", function() require("quarto.runner").run_all(true) end,    desc = "run all cells (all langs)", ft = "quarto", silent = true },

            -- otter
            { "<localleader>qe", function() require("otter").export(false) end,            desc = "export code to files", ft = "quarto", silent = true },
            { "<localleader>qE", function() require("otter").export(true) end,             desc = "export code (overwrite)", ft = "quarto", silent = true },

            { "<localleader>ti", ":split term://ipython<cr>", desc = "terminal: ipython", ft = "quarto" },
            { "<localleader>tp", ":split term://python<cr>", desc = "terminal: python", ft = "quarto" },
        },
    },

    -- directly open ipynb files as quarto docuements
    -- and convert back behind the scenes
    -- `pip install jupytext`
    {
        "GCBallesteros/jupytext.nvim",
        enabled = not vim.wo.diff,
        opts = {
            custom_language_formatting = {
                python = {
                    extension = "qmd",
                    style = "quarto",
                    force_ft = "quarto",
                },
                r = {
                    extension = "qmd",
                    style = "quarto",
                    force_ft = "quarto",
                },
            },
        },
    },

    {
        "hrsh7th/nvim-cmp",
        dependencies = { "jmbuhr/otter.nvim" },
        ---@param opts cmp.ConfigSchema
        opts = function(_, opts)
            local cmp = require("cmp")
            opts.sources = cmp.config.sources(vim.list_extend(opts.sources, { { name = "otter" } }))
        end,
    },

    {
        "Kicamon/markdown-table-mode.nvim",
        opts = {
            filetype = { "*.qmd" },
        },
    },

    {
        "HakonHarnes/img-clip.nvim",
        ft = { "quarto" },
        opts = {
            file_types = {
                quarto = {
                    template = "![$CURSOR]($FILE_PATH){#fig-$LABEL width=80%}",
                },
            },
        },
    },

    {
        "neovim/nvim-lspconfig",
        ---@class PluginLspOpts
        opts = {
            servers = {
                pyright = {},
                -- r_language_server = {},
                -- julials = {},
                marksman = {
                    -- also needs:
                    -- $home/.config/marksman/config.toml :
                    -- [core]
                    -- markdown.file_extensions = ["md", "markdown", "qmd"]
                    filetypes = { "markdown", "quarto" },
                    root_dir = require("lspconfig.util").root_pattern(".git", ".marksman.toml", "_quarto.yml"),
                },
            },
        },
    },
}
