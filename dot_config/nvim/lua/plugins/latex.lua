--- tex.vim -- LaTex specific settings
--- Commentary:
--- LaTex in Vim using [VimTex](https://github.com/lervag/vimtex)
--- |======|=========================|======|
--- | LHS  |           RHS           | MODE |
--- |======|=========================|======|
--- | dse  | delete-surrounding-env  |  n   |
--- | dsc  | delete-surrounding-cmd  |  n   |
--- | dsm  | delete-surrounding-math |  n   |
--- | cse  | change-surrounding-env  |  n   |
--- | csc  | change-surrounding-cmd  |  n   |
--- | csm  | change-surrounding-math |  n   |
--- | tse  | toggle-surrounding-env  |  n   |
--- | tsd  | toggle-delim-modifier   |  nx  |
--- | <F7> | create-cmd-inplace      |  ni  |
--- | ]]   | insert-close-delim      |  i   |
--- |======|=========================|======|
---
--- Code:

return {
    {
        "lervag/vimtex",
        lazy = false, -- lazy-loading will disable inverse search
        ft = "tex",
        -- stylua: ignore
        keys = {
            { "K", mode = { "n" }, "5k", silent = true },

            { "<localleader>t", mode = { "n" }, "<Plug>(vimtex-toc-open)", desc = "Open TOC" },
            { "<localleader>e", mode = { "n" }, "<Plug>(vimtex-errors)", desc = "Show errors" },
            { "<localleader>c", mode = { "n" }, "<Cmd>write<CR><Cmd>VimtexCompile<CR>", desc = "Compile" },
            { "<localleader>r", mode = { "n" }, "<Plug>(vimtex-reload)", desc = "Reload" },
            { "<localleader>w", mode = { "n" }, "<Cmd>VimtexCountWords<CR>", desc = "Count words" },
            { "<localleader>z", mode = { "n" }, "<Plug>(vimtex-clean)", desc = "Clean auxiliary files" },
            { "<localleader>Z", mode = { "n" }, "<Plug>(vimtex-clean-full)", desc = "Clean all outputs" },

            -- o: +open
            { "<localleader>oi", mode = { "n" }, "<Plug>(vimtex-info)", desc = "info" },
            { "<localleader>oI", mode = { "n" }, "<Plug>(vimtex-info-full)", desc = "info-full" },
            { "<localleader>ot", mode = { "n" }, "<Plug>(vimtex-toc-toggle)", desc = "toggle-toc" },
            { "<localleader>os", mode = { "n" }, "<Plug>(vimtex-status)", desc = "status" },
            { "<localleader>oS", mode = { "n" }, "<Plug>(vimtex-status-full)", desc = "status-full" },

            -- Forward search
            { "<localleader>f", mode = { "n" }, "<Cmd>VimtexView<CR>", desc = "scroll-sync-PDF" },
            -- NOTE: To perform reverse-search, <cmd+S>+<LeftClick> in the PDF Reader

            { "dsm", mode = { "n" }, "<Plug>(vimtex-env-delete-math)", desc = "Delete surr math" },
            { "csm", mode = { "n" }, "<Plug>(vimtex-cmd-change-math)", desc = "Change surr math" },
            -- Use `ai` and `ii` for the item text object
            { "ii", mode = { "x" }, "<Plug>(vimtex-im)" },
            { "ii", mode = { "o" }, "<Plug>(vimtex-im)" },
            { "ai", mode = { "x" }, "<Plug>(vimtex-am)" },
            { "ai", mode = { "o" }, "<Plug>(vimtex-am)" },
            -- Use `am` and `im` for the inline math text object
            { "im", mode = { "x" }, "<Plug>(vimtex-i$)" },
            { "im", mode = { "o" }, "<Plug>(vimtex-i$)" },
            { "am", mode = { "x" }, "<Plug>(vimtex-a$)" },
            { "am", mode = { "o" }, "<Plug>(vimtex-a$)" },

            -- Utils
            { "<localleader>i", mode = { "n" }, "<Plug>(vimtex-imaps-list)", desc = "Show imap list" },
            { "<localleader>pk", mode = { "n" }, "<Plug>(vimtex-stop)", desc = "Stop VimTex" },
            { "<localleader>pK", mode = { "n" }, "<Plug>(vimtex-stop-all)", desc = "Stop VimTex all" },
        },
        config = function()
            vim.api.nvim_create_autocmd({ "FileType" }, {
                group = vim.api.nvim_create_augroup("lazyvim_vimtex_conceal", { clear = true }),
                pattern = { "bib", "tex" },
                callback = function()
                    vim.wo.conceallevel = 2
                end,
            })

            vim.g.tex_flavor = "latex"
            vim.g.vimtex_compiler_progname = "nvr" -- use pip install neovim-remote
            vim.g.vimtex_compiler_latexmk_engines = {
                ["_"] = "-xelatex", -- default value
                ["pdfdvi"] = "-pdfdvi",
                ["pdfps"] = "-pdfps",
                ["pdflatex"] = "-pdf",
                ["luatex"] = "-lualatex",
                ["lualatex"] = "-lualatex",
                ["xelatex"] = "-xelatex",
                ["context (pdftex)"] = "-pdf -pdflatex=texexec",
                ["context (luatex)"] = "-pdf -pdflatex=context",
                ["context (xetex)"] = "-pdf -pdflatex='texexec --xtx'",
            }
            if vim.fn.has("mac") == 1 then
                -- Currently Skim has bug that prevents forward searching
                -- vim.g.vimtex_view_method = "skim"
                -- vim.g.vimtex_view_skim_sync = 1
                -- vim.g.vimtex_view_skim_activate = 1
                -- vim.g.vimtex_view_skim_no_select = 1 -- Set this option to 1 to prevent Skim from selecting the text after command |:VimtexView| or compiler callback.
                -- vim.g.vimtex_view_skim_reading_bar = 1

                vim.g.vimtex_view_method = "sioyek"
                vim.g.vimtex_view_sioyek_options = "--nofocus --reuse-window" -- --nofocus not working?
            elseif vim.fn.has("win32") == 1 then
                vim.g.vimtex_view_general_viewer = "SumatraPDF"
                vim.g.vimtex_view_general_options = "-reuse-instance -forward-search @tex @line @pdf"
                    .. ' -inverse-search "wt -w 0 \\"\\" nvim --headless -c \\"VimtexInverseSearch %l \'%f\'\\""'
            end

            -- vim.g.vimtex_mappings_disable = { ["n"] = { "K" } }
            vim.g.vimtex_quickfix_method = vim.fn.executable("pplatex") == 1 and "pplatex" or "latexlog"

            vim.g.vimtex_quickfix_mode = 0 -- quickfix auto pop up
            vim.g.vimtex_quickfix_ignore_filters = {
                "does not contain requested Script",
                "Overfull",
                "Underfull",
            }

            -- Disable imaps
            vim.g.vimtex_imaps_enabled = 0
            -- vim.g.vimtex_view_automatic = 0

            -- Auto refocus neovim (not working for sioyek)
            local function tex_focus_vim()
                if vim.fn.has("mac") == 1 then
                    if vim.g.neovide then
                        vim.cmd("silent !open -a Neovide")
                    else
                        vim.cmd("silent !open -a iTerm")
                    end
                elseif vim.fn.has("win32") == 1 then
                    if vim.g.neovide then
                        vim.cmd("silent !Show-Window Neovide")
                    else
                        vim.cmd("silent !Show-Window WindowsTerminal")
                    end
                end
                vim.cmd("redraw!")
            end

            vim.api.nvim_create_augroup("vimtex_event_focus", { clear = true })
            vim.api.nvim_create_autocmd("User", {
                pattern = "VimtexEventViewReverse",
                group = "vimtex_event_focus",
                callback = tex_focus_vim,
            })
            vim.api.nvim_create_autocmd("User", {
                pattern = "VimtexEventView",
                group = "vimtex_event_focus",
                callback = tex_focus_vim,
            })

            require("which-key").add({
                { "<localLeader>l", group = "vimtex" },
                { "<localLeader>o", group = "open" },
                { "<localLeader>p", group = "plugin" },
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                texlab = {
                    keys = {
                        { "<localLeader>h", "<plug>(vimtex-doc-package)", desc = "Vimtex Docs", silent = true },
                    },
                },
            },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            if type(opts.ensure_installed) == "table" then
                vim.list_extend(opts.ensure_installed, {
                    "bibtex",
                    "latex",
                })
            end
            if type(opts.highlight.disable) == "table" then
                vim.list_extend(opts.highlight.disable, {
                    "latex",
                })
            else
                opts.highlight.disable = {
                    "latex",
                }
            end
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = { "kdheepak/cmp-latex-symbols" },
        opts = function(_, opts)
            if vim.bo.filetype == "tex" then
                table.insert(opts.sources, { name = "latex_symbols", option = { strategy = 1 } })
                table.insert(opts.sources, { name = "dictionary", option = { keyword_length = 2 } })
            end
        end,
    },
}
