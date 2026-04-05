-- Plugin that show messages in floating flexible windows

return {
    {
        "folke/noice.nvim",
        -- cursor flickering bug (trace: https://github.com/folke/noice.nvim/issues/923)
        -- commit = "d9328ef",
        enabled = not (vim.g.started_by_firenvim or _G.disable_plugins.noice),
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        opts = {
            cmdline = {
                view = "cmdline", -- use native bottom cmdline instead of floating popup
            },
            signature = {
                enabled = true,
                auto_open = {
                    enabled = true,
                },
            },
            ---@type NoicePresets
            presets = {
                bottom_search = true, -- use a classic bottom cmdline for search
            },
            -- disable some messages
            routes = {
                -- Hide "written" confirmation after :w
                {
                    filter = { event = "msg_show", find = "written" },
                    opts = { skip = true },
                },
                -- Hide "chezmoi" output when auto apply chezmoi
                {
                    filter = { event = "msg_show", find = ":!chezmoi" },
                    opts = { skip = true },
                },
                -- Show :!cmd shell output in a split with cursor focus
                {
                    filter = { event = "msg_show", kind = { "shell_cmd", "shell_out" } },
                    view = "split",
                    opts = { enter = true, size = "80%" },
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
        },
    },
    {
        "rcarriga/nvim-notify",
        enabled = not _G.disable_plugins.notify,
        opts = {
            fps = 60,
            timeout = 3500,
            render = "wrapped-compact", -- default, minimal, simple, compact, wrapped-compact
            stages = "static", -- fade_in_slide_out, fade, slide, static
        },
    },
}
