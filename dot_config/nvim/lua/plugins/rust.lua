return {
    -- Install code highlighter
    {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
            if type(opts.ensure_installed) == "table" then
                vim.list_extend(opts.ensure_installed, {
                    "rust",
                    "toml",
                })
            end
        end,
    },
    -- Install lsp and dap
    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            if type(opts.ensure_installed) == "table" then
                vim.list_extend(opts.ensure_installed, {
                    "codelldb",
                    "clang-format",
                })
            end
        end,
    },

    -- Correctly setup lspconfig for Rust 🚀
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                -- Ensure mason installs the server
                rust_analyzer = {
                    keys = {
                        { "<Leader>h", "<cmd>RustHoverActions<cr>", desc = "Hover Actions (Rust)" },
                        { "<leader>cR", "<cmd>RustCodeAction<cr>", desc = "Code Action (Rust)" },
                        { "<leader>dr", "<cmd>RustDebuggables<cr>", desc = "Run Debuggables (Rust)" },
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
                    },
                },
            },
        },
    },

    -- formatter config
    {
        "nvimtools/none-ls.nvim",
        opts = function(_, opts)
            if type(opts.sources) == "table" then
                local nls = require("null-ls")
                vim.list_extend(opts.sources, {
                    nls.builtins.formatting.rustfmt,
                })
            end
        end,
    },
}
