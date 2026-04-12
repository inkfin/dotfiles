if _G.disable_plugins.c3 then
    return {}
end

return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                c3_lsp = {},
            },
        },
    },
}
