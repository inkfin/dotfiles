-- Plugin that show messages in floating flexible windows

return {
    {
        "folke/noice.nvim",
        -- cursor flickering bug (trace: https://github.com/folke/noice.nvim/issues/923)
        -- commit = "d9328ef",
        enabled = not (vim.g.started_by_firenvim or _G.disable_plugins.noice),
        opts = {
            views = {
                cmdline_popup = {
                    position = {
                        row = -2,
                        col = "50%",
                    },
                },
                cmdline_popupmenu = {
                    position = {
                        row = -5,
                        col = "50%",
                    },
                },
            },
            preset = {
                cmdline_output_to_split = true,
            },
            -- disable some messages
            routes = {
                {
                    skip = true,
                    filter = { event = "msg_show", find = ":!chezmoi" },
                },
            },
        },
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
    },
    {
        "rcarriga/nvim-notify",
        enabled = not _G.disable_plugins.notify,
        opts = {
            fps = 60,
            timeout = 3500,
            render = "wrapped-compact", -- default, minimal, simple, compact, wrapped-compact
            stages = "fade", -- fade_in_slide_out, fade, slide, static
        },
    },
}
