if _G.disable_plugins.harper then
    return {}
end

-- vim.opt.spell = false

return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                harper_ls = {
                    settings = {
                        ["harper-ls"] = {
                            userDictPath = vim.fn.stdpath("config") .. "/spell/en.utf-8.add",
                            codeActions = {
                                forceStable = true,
                            },
                        },
                    },
                },
            },
        },
    },
}
