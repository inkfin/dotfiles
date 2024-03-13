-- if true then return {} end

return {
    -- Correctly setup lspconfig for Rust 🚀
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
                -- Ensure mason installs the server
                rust_analyzer = {},
                taplo = {
                    keys = {
                        {
                            "<leader>h",
                            function()
                                if vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
                                    require("crates").show_popup()
                                else
                                    vim.lsp.buf.hover()
                                end
                            end,
                            desc = "Show Crate Documentation",
                        },
                        { "K", false },
                    },
                },
            },
        },
    },
    -- rustfmt: https://rust-lang.github.io/rustfmt/
    -- rustaceanvim: https://github.com/mrcjkb/rustaceanvim
    {
        "mrcjkb/rustaceanvim",
        opts = {
            server = {
                on_attach = function(_, bufnr)
                    vim.keymap.set("n", "<leader>h", function()
                        vim.cmd.RustLsp({ "hover", "actions" })
                    end, { desc = "Hover Actions (Rust)", buffer = bufnr })

                    vim.keymap.set("n", "<leader>ca", function()
                        vim.cmd.RustLsp("codeAction")
                    end, { desc = "Code Action", buffer = bufnr })
                    vim.keymap.set("n", "<leader>dr", function()
                        vim.cmd.RustLsp("debuggables")
                    end, { desc = "Rust debuggables", buffer = bufnr })
                end,
            },
        },
    },
}
