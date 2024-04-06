-- not using lazyvim's language preset, control plugins by ourselves

return {
    {
        "iamcco/markdown-preview.nvim",
        ft = "markdown",
        lazy = true,
        config = function()
            -- options for markdown render
            vim.g.mkdp_preview_options = {
                -- mkit: markdown-it options for render
                mkit = {},
                -- katex: katex options for math
                katex = {},
                -- uml: markdown-it-plantuml options
                uml = {},
                -- maid: mermaid options
                maid = {},
                -- disable_sync_scroll: if disable sync scroll, default 0
                disable_sync_scroll = 0,
                -- sync_scroll_type: 'middle', 'top' or 'relative', default value is 'middle'
                --   middle: mean the cursor position alway show at the middle of the preview page
                --   top: mean the vim top viewport alway show at the top of the preview page
                --   relative: mean the cursor position alway show at the relative positon of the preview page
                sync_scroll_type = "middle",
                -- hide_yaml_meta: if hide yaml metadata, default is 1
                hide_yaml_meta = 0,
                -- sequence_diagrams: js-sequence-diagrams options
                sequence_diagrams = {},
                flowchart_diagrams = {},
                -- content_editable: if enable content editable for preview page, default: v:false
                content_editable = false,
                -- disable_filename: if disable filename header for preview page, default: 0
                disable_filename = 1,
                toc = {},
            }
        end,
    },
    {
        "lukas-reineke/headlines.nvim",
        opts = function()
            local opts = {}
            for _, ft in ipairs({ "markdown", "quarto", "norg", "rmd", "org" }) do
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
        ft = { "markdown", "quarto", "norg", "rmd", "org" },
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
