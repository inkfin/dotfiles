-- Plugin that show messages in floating flexible windows

return {
    "folke/noice.nvim",
    keys = {
        -- change scrolling keymap to <C-d/u> (can affect LSP)
        {
            "<C-d>",
            function()
                if not require("noice.lsp").scroll(4) then
                    return "<C-d>"
                end
            end,
            silent = true,
            expr = true,
            desc = "Scroll forward",
            mode = { "i", "n", "s" },
        },
        {
            "<C-u>",
            function()
                if not require("noice.lsp").scroll(-4) then
                    return "<C-u>"
                end
            end,
            silent = true,
            expr = true,
            desc = "Scroll backward",
            mode = { "i", "n", "s" },
        },
        { "<leader>fN", "<Cmd>Noice telescope<CR>", silent = true, desc = "Noice messages" },
    },
}
