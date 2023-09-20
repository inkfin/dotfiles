return {
    {
        "L3MON4D3/LuaSnip",
        opts = {
            history = true,
            delete_check_events = "TextChanged",
        },
        -- don't map keys since it is taken over by nvim-cmp
    },
    {
        "rafamadriz/friendly-snippets",
        config = function()
            require("luasnip").filetype_extend("csharp", { "unity" })
            require("luasnip").filetype_extend("cpp", { "unreal" })
            require("luasnip.loaders.from_vscode").load({ paths = { "./template/snippets" } })
            require("luasnip.loaders.from_vscode").load_standalone({
                path = "./template/snippets/global.code-snippets",
            })
            require("luasnip.loaders.from_vscode").lazy_load()
        end,
        keys = {
            -- stylua: ignore
            { "<leader>oS", function()
                    require("luasnip.loaders").edit_snippet_files()
                end, mode = "n", desc = "Snippet Edit" },
        },
    },
}
