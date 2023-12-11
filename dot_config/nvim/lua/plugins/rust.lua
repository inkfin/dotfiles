-- if true then return {} end

return {
    -- Correctly setup lspconfig for Rust 🚀
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
                -- Ensure mason installs the server
                rust_analyzer = {
                    keys = {
                        { "<Leader>h", "<cmd>RustHoverActions<cr>", desc = "Hover Actions (Rust)" },
                        { "<leader>cR", "<cmd>RustCodeAction<cr>", desc = "Code Action (Rust)" },
                        { "<leader>dr", "<cmd>RustDebuggables<cr>", desc = "Run Debuggables (Rust)" },
                        { "K", false },
                    },
                },
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
}
