return {
    {
        "voldikss/vim-translator",
        --stylua: ignore
        keys = {
            { "<leader>ts", mode = { "n" }, "<Plug>Translate", desc = "Translate" },
            { "<leader>ts", mode = { "v" }, "<Plug>TranslateV", desc = "Translate selected" },
            { "<leader>tw", mode = { "n" }, "<Plug>TranslateW", desc = "Translate Window" },
            { "<leader>tw", mode = { "v" }, "<Plug>TranslateWV", desc = "Translate Window" },
            { "<leader>tr", mode = { "n" }, "<Plug>TranslateR", desc = "Translate and Replace" },
            { "<leader>tr", mode = { "v" }, "<Plug>TranslateRV", desc = "Translate and Replace" },
            { "<leader>tx", mode = { "n" }, "<Plug>TranslateX", desc = "Translate Clipboard" },
        },
        config = function()
            vim.g.translator_target_lang = "zh"
            vim.g.translator_default_engines = { "google", "youdao", "haici", "bing" }
            vim.g.translator_history_enable = true

            vim.cmd([[
                nnoremap <silent><expr> <C-d> translator#window#float#has_scroll() ?
                                            \ translator#window#float#scroll(1) : "\<C-d>"
                nnoremap <silent><expr> <C-u> translator#window#float#has_scroll() ?
                                            \ translator#window#float#scroll(0) : "\<C-u>"
            ]])
        end,
    },
}
