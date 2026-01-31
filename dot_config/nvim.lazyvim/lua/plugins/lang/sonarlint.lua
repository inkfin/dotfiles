if _G.disable_plugins.sonarlint then
    return {}
end

return {
    {
        "mason-org/mason.nvim",
        opts = function(_, opts)
            -- install sonarlint-language-server
            if type(opts.ensure_installed) == "table" then
                vim.list_extend(opts.ensure_installed, {
                    "sonarlint-language-server",
                })
            end

            -- -- referenced from https://gitlab.com/schrieveslaach/sonarlint.nvim#for-installation-via-masonnvim
            -- require("sonarlint").setup({
            --     server = {
            --         cmd = {
            --             "sonarlint-language-server",
            --             -- Ensure that sonarlint-language-server uses stdio channel
            --             "-stdio",
            --             "-analyzers",
            --             -- paths to the analyzers you need, using those for python and java in this example
            --             vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarpython.jar"),
            --             vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarcfamily.jar"),
            --             vim.fn.expand("$MASON/share/sonarlint-analyzers/sonarjava.jar"),
            --         },
            --     },
            --     filetypes = {
            --         -- Tested and working
            --         "python",
            --         "cpp",
            --         -- Requires nvim-jdtls, otherwise an error message will be printed
            --         -- "java",
            --     },
            -- })
        end,
    },
}
