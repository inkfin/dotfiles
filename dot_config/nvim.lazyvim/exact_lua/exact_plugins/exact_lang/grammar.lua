if _G.disable_plugins.harper then
    return {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                harper_ls = {
                    enabled = false,
                },
            },
        },
    }
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
                                ForceStable = true,
                            },
                            linters = {
                                ToDoHyphen = false,
                                SpellCheck = false, -- use vim spellcheck
                                SpelledNumbers = false,
                                AnA = true,
                                SentenceCapitalization = false,
                                UnclosedQuotes = true,
                                WrongQuotes = false,
                                LongSentences = true,
                                RepeatedWords = true,
                                Spaces = true,
                                Matcher = true,
                                CorrectNumberSuffix = true,
                            },
                            markdown = {
                                -- [ignores this part]()
                                -- [[ also ignores my marksman links ]]
                                IgnoreLinkTitle = true,
                            },
                        },
                    },
                },
            },
        },
    },
}
