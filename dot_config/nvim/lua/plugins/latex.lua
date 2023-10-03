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
        {
            "lervag/vimtex",
            lazy = false, -- lazy-loading will disable inverse search
            -- stylua: ignore
            keys = {
                { "K", mode = { "n" }, "5k", silent = true },

                { "<localleader>t", mode = { "n" }, "<Plug>(vimtex-toc-toggle)", desc = "Toggle TOC" },
                { "<localleader>e", mode = { "n" }, "<Plug>(vimtex-errors)", desc = "Show errors" },
                { "<localleader>c", mode = { "n" }, "<Cmd>write<CR><Cmd>VimtexCompile<CR>", desc = "Compile" },
                { "<localleader>r", mode = { "n" }, "<Plug>(vimtex-reload)", desc = "Reload" },
                { "<localleader>w", mode = { "n" }, "<Cmd>VimtexCountWords<CR>", desc = "Count words" },
                { "<localleader>z", mode = { "n" }, "<Plug>(vimtex-clean)", desc = "Clean auxiliary files" },
                { "<localleader>Z", mode = { "n" }, "<Plug>(vimtex-clean-full)", desc = "Clean all outputs" },

                -- o: +open
                { "<localleader>oi", mode = { "n" }, "<Plug>(vimtex-info)", desc = "info" },
                { "<localleader>oI", mode = { "n" }, "<Plug>(vimtex-info-full)", desc = "info-full" },
                { "<localleader>ot", mode = { "n" }, "<Plug>(vimtex-toc-open)", desc = "toc" },
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
                if vim.fn.has("mac") == 1 then
                    vim.g.vimtex_view_method = "skim"
                    vim.g.vimtex_view_general_viewer = "open -a /Applications/Skim.app "
                    vim.g.vimtex_view_skim_sync = 1
                    vim.g.vimtex_view_skim_activate = 1
                    vim.g.vimtex_view_skim_reading_bar = 1
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
                }

                -- Disable imaps
                vim.g.vimtex_imaps_enabled = 0
                -- vim.g.vimtex_view_automatic = 0

                if vim.fn.has("mac") == 1 then
                    vim.cmd([[
                        augroup vimtex_event_focus
                            au!
                            au User VimtexEventViewReverse call g:TexFocusVim()
                            au User VimtexEventView call g:TexFocusVim()
                        augroup END

                        function! g:TexFocusVim() abort
                            if exists("g:neovide")
                                silent execute "!open -a Neovide"
                            else
                                silent execute "!open -a iTerm"
                            endif
                            redraw!
                        endfunction
                    ]])
                elseif vim.fn.has("win32") == 1 then
                    vim.cmd([[
                        augroup vimtex_event_focus
                            au!
                            au User VimtexEventViewReverse call g:TexFocusVim()
                            au User VimtexEventView call g:TexFocusVim()
                        augroup END

                        function! g:TexFocusVim() abort
                            if exists("g:neovide")
                                silent execute "!Show-Window Neovide"
                            else
                                silent execute "!Show-Window WindowsTerminal"
                            endif
                            redraw!
                        endfunction
                    ]])
                end
            end,
        },
        {
            "neovim/nvim-lspconfig",
            optional = true,
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
            "folke/which-key.nvim",
            optional = true,
            opts = {
                defaults = {
                    ["<localLeader>l"] = { name = "+vimtex" },
                    ["<localLeader>o"] = { name = "+open" },
                    ["<localLeader>p"] = { name = "+plugin" },
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
    },
}
