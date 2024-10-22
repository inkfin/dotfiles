if _G.disable_plugins.python then
    return {}
end

return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                pyright = {
                    settings = {
                        python = {
                            analysis = {
                                -- typeCheckingMode = "off",
                            },
                        },
                    },
                },
            },
        },
    },
}
