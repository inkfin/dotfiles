if _G.disable_plugins.org then
    return {}
end

return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            -- add tsx and treesitter
            opts.highlight.enable = true
            vim.list_extend(opts.ensure_installed, { "org" })
            if opts.highlight.additional_vim_regex_highlighting == nil then
                opts.highlight.additional_vim_regex_highlighting = {}
            end
            vim.list_extend(opts.highlight.additional_vim_regex_highlighting, { "org" })
        end,
    },
    {
        "nvim-orgmode/orgmode",
        dependencies = {
            { "nvim-treesitter/nvim-treesitter", lazy = true },
        },
        event = "VeryLazy",
        config = function()
            -- Load treesitter grammar for org
            -- require("orgmode").setup_ts_grammar()

            -- Setup orgmode
            require("orgmode").setup({
                org_agenda_files = "~/orgfiles/**/*",
                org_default_notes_file = "~/orgfiles/refile.org",
            })
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        ---@param opts cmp.ConfigSchema
        opts = function(_, opts)
            local cmp = require("cmp")
            opts.sources = cmp.config.sources(vim.list_extend(opts.sources, { { name = "orgmode" } }))
        end,
    },
}
