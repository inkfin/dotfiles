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
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "quarto", "norg", "rmd", "org", "tex" },
        opts = {
            file_types = { "markdown", "quarto", "norg", "rmd", "org", "tex" },
            --- Styles: https://github.com/MeanderingProgrammer/render-markdown.nvim/wiki#components
            code = {
                sign = true,
                width = "block",
                border = "thick",
                left_pad = 0,
                right_pad = 4,
                min_width = 45,
            },
            heading = {
                sign = true,
            },
            pipe_table = {
                -- preset = "double",
                style = "normal",
            },
            latex = {
                enabled = false,
            },
        },
    },

    -- {
    --     "lukas-reineke/headlines.nvim",
    --     opts = function()
    --         local opts = {}
    --         for _, ft in ipairs({ "markdown", "quarto", "norg", "rmd", "org" }) do
    --             opts[ft] = {
    --                 headline_highlights = {},
    --                 fat_headline_lower_string = "▀",
    --             }
    --             for i = 1, 6 do
    --                 local hl = "Headline" .. i
    --                 vim.api.nvim_set_hl(0, hl, { link = "Headline", default = true })
    --                 table.insert(opts[ft].headline_highlights, hl)
    --             end
    --         end
    --         return opts
    --     end,
    --     ft = { "markdown", "quarto", "norg", "rmd", "org" },
    --     config = function(_, opts)
    --         -- PERF: schedule to prevent headlines slowing down opening a file
    --         vim.schedule(function()
    --             require("headlines").setup(opts)
    --             require("headlines").refresh()
    --         end)
    --     end,
    -- },

    {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        ft = { "markdown" },
        opts = {
            default = {
                dir_path = "assets",
            },
            file_types = {
                markdown = {
                    template = "![$CURSOR]($FILE_PATH)",
                },
            },
        },
        keys = {
            { "<leader>pi", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
            {
                "<leader>pI",
                function()
                    local telescope = require("telescope.builtin")
                    local actions = require("telescope.actions")
                    local action_state = require("telescope.actions.state")

                    telescope.find_files({
                        attach_mappings = function(_, map)
                            local function embed_image(prompt_bufnr)
                                local entry = action_state.get_selected_entry()
                                local filepath = entry[1]
                                actions.close(prompt_bufnr)

                                local img_clip = require("img-clip")
                                img_clip.paste_image(nil, filepath)
                            end

                            map("i", "<CR>", embed_image)
                            map("n", "<CR>", embed_image)

                            return true
                        end,
                        desc = "Select image to embed",
                    })
                end,
            },
        },
    },

    -- paste an image to markdown from the clipboard
    -- :PasteImg,
    -- {
    --     "dfendr/clipboard-image.nvim",
    --     ft = { "quarto", "markdown" },
    --     keys = {
    --         { "<leader>pi", "<cmd>PasteImg<cr>", silent = true, desc = "image paste" },
    --     },
    --     cmd = {
    --         "PasteImg",
    --     },
    --     opts = {
    --         quarto = {
    --             img_dir = { "%:p:h", "assets" },
    --             affix = "![](%s)",
    --         },
    --         markdown = {
    --             img_dir = { "%:p:h", "assets" },
    --             img_dir_txt = "assets",
    --             affix = "![](%s)",
    --             -- Insert alt-text with img_handler (https://github.com/ekickx/clipboard-image.nvim/discussions/15#discussioncomment-2170666)
    --             img_handler = function(img)
    --                 vim.cmd("normal! f[") -- go to [
    --                 vim.cmd("normal! a" .. img.name) -- append text with image name
    --             end,
    --         },
    --     },
    -- },

    -- preview equations
    {
        "jbyuki/nabla.nvim",
        ft = { "quarto", "tex", "markdown" },
        -- stylua: ignore
        keys = {
            { "<leader>pe", function() require("nabla").toggle_virt() end, desc = "toggle equations", ft = { "quarto", "tex", "markdown" } },
            { "<leader>ph", function() require"nabla".popup() end, desc = "hover equation", ft = { "quarto", "tex", "markdown" } },
        },
    },

    {
        "Kicamon/markdown-table-mode.nvim",
        opts = {
            filetype = { "*.md" },
        },
    },

    -- export pdf
    {
        "jghauser/auto-pandoc.nvim",
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
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "uga-rosa/cmp-dictionary",
            opts = {
                paths = { vim.fn.stdpath("config") .. "/spell/en.dict" },
                exact_length = 2,
                first_case_insenstive = false,
            },
        },
        opts = function(_, opts)
            local enable_filetype = {
                ["markdown"] = true,
                ["org"] = true,
                ["text"] = true,
            }
            if enable_filetype[vim.bo.filetype] then
                table.insert(opts.sources, { name = "dictionary", option = { keyword_length = 2 } })
            end
        end,
    },
}
