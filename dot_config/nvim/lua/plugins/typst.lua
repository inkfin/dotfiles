if _G.disable_plugins.typst then
    return {}
end

return {
    -- web preview
    --   reference: <https://myriad-dreamin.github.io/tinymist//frontend/neovim.html#label-live-preview>
    {
        "chomosuke/typst-preview.nvim",
        enabled = vim.fn.executable("typst") == 1,
        ft = "typst",
        opts = {
            -- Custom format string to open the output link provided with %s
            -- Example: open_cmd = 'firefox %s -P typst-preview --class typst-preview'
            open_cmd = nil,
            invert_colors = "auto",
            -- A list of extra arguments (or nil) to be passed to previewer.
            -- For example, extra_args = { "--input=ver=draft", "--ignore-system-fonts" }
            extra_args = nil,
            dependencies_bin = {
                ["tinymist"] = "tinymist", -- use mason installation
                ["websocat"] = nil,
            },
        },
        keys = {
            { "<localleader>c", mode = { "n" }, "<CMD>TypstPreviewToggle<CR>", desc = "Toggle Preview", ft = "typst" },
            {
                "<localleader>f",
                mode = { "n" },
                "<CMD>TypstPreviewSyncCursor<CR>",
                desc = "Sync Cursor Pos",
                ft = "typst",
            },
            {
                "<localleader>F",
                mode = { "n" },
                "<CMD>TypstPreviewFollowCursorToggle<CR>",
                desc = "Toggle Always Follow Cursor",
                ft = "typst",
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                tinymist = {
                    projectResolution = "lockDatabase",
                    exportPdf = "onDocumentHasTitle",
                    formatterMode = "typstyle",
                },
            },
        },
    },
}
