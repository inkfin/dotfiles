-- not using lazyvim's language preset, control plugins by ourselves

return {
    {
        "iamcco/markdown-preview.nvim",
        ft = "markdown",
        lazy = true,
        config = function()
            vim.cmd([[
                " options for markdown render
                " mkit: markdown-it options for render
                " katex: katex options for math
                " uml: markdown-it-plantuml options
                " maid: mermaid options
                " disable_sync_scroll: if disable sync scroll, default 0
                " sync_scroll_type: 'middle', 'top' or 'relative', default value is 'middle'
                "   middle: mean the cursor position alway show at the middle of the preview page
                "   top: mean the vim top viewport alway show at the top of the preview page
                "   relative: mean the cursor position alway show at the relative positon of the preview page
                " hide_yaml_meta: if hide yaml metadata, default is 1
                " sequence_diagrams: js-sequence-diagrams options
                " content_editable: if enable content editable for preview page, default: v:false
                " disable_filename: if disable filename header for preview page, default: 0
                let g:mkdp_preview_options = {
                    \ 'mkit': {},
                    \ 'katex': {},
                    \ 'uml': {},
                    \ 'maid': {},
                    \ 'disable_sync_scroll': 0,
                    \ 'sync_scroll_type': 'middle',
                    \ 'hide_yaml_meta': 0,
                    \ 'sequence_diagrams': {},
                    \ 'flowchart_diagrams': {},
                    \ 'content_editable': v:false,
                    \ 'disable_filename': 1,
                    \ 'toc': {}
                    \ }
            ]])
        end,
    },
    {
        "lukas-reineke/headlines.nvim",
        opts = function()
            local opts = {}
            for _, ft in ipairs({ "markdown", "norg", "rmd", "org" }) do
                opts[ft] = {
                    headline_highlights = {},
                    fat_headline_lower_string = "▀",
                }
                for i = 1, 6 do
                    local hl = "Headline" .. i
                    vim.api.nvim_set_hl(0, hl, { link = "Headline", default = true })
                    table.insert(opts[ft].headline_highlights, hl)
                end
            end
            return opts
        end,
        ft = { "markdown", "norg", "rmd", "org" },
        config = function(_, opts)
            -- PERF: schedule to prevent headlines slowing down opening a file
            vim.schedule(function()
                require("headlines").setup(opts)
                require("headlines").refresh()
            end)
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            if type(opts.ensure_installed) == "table" then
                vim.list_extend(opts.ensure_installed, { "markdown", "markdown_inline" })
            end
        end,
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                marksman = {},
            },
        },
    },
}
