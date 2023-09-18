return {
    {
        "L3MON4D3/LuaSnip",
        opts = {
            history = true,
            delete_check_events = "TextChanged",
        },
        -- stylua: ignore
        keys = {
            {
              "<tab>",
              function()
                  return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
              end,
              expr = true, silent = true, mode = "i",
            },
            { "<tab>", function() require("luasnip").jump(1) end, mode = "s" },
            { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
        },
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
