-- LuaSnip
vim.api.nvim_create_user_command("LuaSnipEdit", function()
    require("luasnip.loaders").edit_snippet_files()
end, { nargs = 0, desc = "Edit LuaSnip of current filetype" })
