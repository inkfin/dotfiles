if _G.disable_plugins.harper then
    local registry = require("mason-registry")
    local names = registry.get_installed_package_names()
    for _, v in ipairs(names) do
        if v == "harper-ls" then
            return {
                "neovim/nvim-lspconfig",
                opts = {
                    servers = {
                        harper_ls = {
                            autostart = false,
                        },
                    },
                },
            }
        end
    end
    return {}
end

-- TODO: https://blob42.xyz/blog/neovim-diagnostic-filtering/

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
                            linters = {
                                spell_check = false,
                            },
                        },
                    },
                },
            },
        },
    },
}
