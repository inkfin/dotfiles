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
                                spelled_numbers = false,
                                an_a = true,
                                sentence_capitalization = false,
                                unclosed_quotes = true,
                                wrong_quotes = false,
                                long_sentences = true,
                                repeated_words = true,
                                spaces = true,
                                matcher = true,
                                correct_number_suffix = true,
                                number_suffix_capitalization = true,
                                multiple_sequential_pronouns = true,
                                linking_verbs = false,
                                avoid_curses = true,
                                terminating_conjunctions = true,
                            },
                        },
                    },
                },
            },
        },
    },
}
