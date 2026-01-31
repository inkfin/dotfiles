if _G.disable_plugins.rust then
    return {}
end

return {
    -- Correctly setup lspconfig for Rust 🚀
    {
        "neovim/nvim-lspconfig",
        opts = {
            setup = {
                -- prevent mason from auto installing rust_analyzer
                rust_analyzer = function()
                    return true
                end,
            },
            servers = {},
        },
    },
    -- rustfmt: https://rust-lang.github.io/rustfmt/
    -- rustaceanvim: https://github.com/mrcjkb/rustaceanvim
    {
        "mrcjkb/rustaceanvim",
        dependencies = {
            {
                "lvimuser/lsp-inlayhints.nvim",
                enabled = vim.fn.has("nvim-0.10") == 0,
            },
        },
        opts = {
            server = {
                on_attach = function(client, bufnr)
                    vim.keymap.set("n", "<leader>ca", function()
                        vim.cmd.RustLsp("codeAction")
                    end, { desc = "Code Action", buffer = bufnr })
                    vim.keymap.set("n", "<leader>dr", function()
                        vim.cmd.RustLsp("debuggables")
                    end, { desc = "Rust debuggables", buffer = bufnr })

                    -- enable inlay hints manually before nvim 0.10
                    if vim.fn.has("nvim-0.10") == 0 then
                        vim.keymap.set("n", "<leader>uI", function()
                            require("lsp-inlayhints").toggle()
                        end, { desc = "Show inlay hint", buffer = bufnr })

                        require("lsp-inlayhints").on_attach(client, bufnr)
                        require("lsp-inlayhints").show()
                    end
                end,
            },
        },
    },
}
