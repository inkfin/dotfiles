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

    -- paste an image to markdown from the clipboard
    -- :PasteImg,
    {
        "dfendr/clipboard-image.nvim",
        ft = { "quarto", "markdown" },
        keys = {
            { "<leader>pi", "<cmd>PasteImg<cr>", silent = true, desc = "image paste" },
        },
        cmd = {
            "PasteImg",
        },
        opts = {
            quarto = {
                img_dir = { "%:p:h", "assets" },
                affix = "![](%s)",
            },
            markdown = {
                img_dir = { "%:p:h", "assets" },
                img_dir_txt = "assets",
                affix = "![](%s)",
                -- Insert alt-text with img_handler (https://github.com/ekickx/clipboard-image.nvim/discussions/15#discussioncomment-2170666)
                img_handler = function(img)
                    vim.cmd("normal! f[") -- go to [
                    vim.cmd("normal! a" .. img.name) -- append text with image name
                end,
            },
        },
    },

    -- preview equations
    {
        "jbyuki/nabla.nvim",
        ft = { "quarto", "tex", "markdown" },
        -- stylua: ignore
        keys = {
            { "<leader>pe", function() require("nabla").toggle_virt() end, desc = "toggle equations" },
            { "<leader>ph", function() require"nabla".popup() end, desc = "hover equation" },
        },
    },

    -- export pdf
    {
        "jghauser/auto-pandoc.nvim",
        -- dir = "C:/Users/11096/Code/Lua/auto-pandoc.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        ft = "markdown",
        keys = {
            {
                "<leader>pE",
                function()
                    require("auto-pandoc").run_pandoc()
                end,
                desc = "Export pdf (pandoc)",
                ft = "markdown", -- this is for buffer-local keymaps
            },
        },
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
