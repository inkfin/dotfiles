-- ~/.config/nvim.mini/lua/plugins/lsp.lua
-- LSP framework: diagnostics UI + global keymaps via LspAttach
-- Individual servers live in lua/lang/*.lua
-- Mason installs missing server binaries automatically.

--------------------------
-- Diagnostics UI
--------------------------
vim.diagnostic.config({
    virtual_text     = { prefix = "●" },
    signs            = true,
    underline        = true,
    update_in_insert = false,
    float = {
        border = "rounded",
        source = true,
    },
})

--------------------------
-- Global on_attach via LspAttach autocommand
--------------------------
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("nvim_mini_lsp_attach", { clear = true }),
    callback = function(ev)
        local bufnr = ev.buf
        local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
        end

        -- Navigation
        map("n", "gd",  vim.lsp.buf.definition,      "Go to definition")
        map("n", "gD",  vim.lsp.buf.declaration,     "Go to declaration")
        map("n", "gi",  vim.lsp.buf.implementation,  "Go to implementation")
        map("n", "gr",  vim.lsp.buf.references,      "References")
        map("n", "gt",  vim.lsp.buf.type_definition, "Go to type definition")

        -- Documentation / hover
        map("n", "K",           vim.lsp.buf.hover,          "Hover docs")
        map("n", "<leader>h",   vim.lsp.buf.hover,          "Hover docs")
        map("i", "<C-k>",       vim.lsp.buf.signature_help, "Signature help")

        -- Actions
        map("n",          "<leader>rn", vim.lsp.buf.rename,      "Rename symbol")
        map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
        map({ "n", "x" }, "<leader>cl", vim.lsp.codelens.run,    "Run codelens")
        map({ "n", "v" }, "<leader>rf", function()
            vim.lsp.buf.format({ async = true })
        end, "Format buffer")

        -- Diagnostics
        map("n", "<leader>cd", vim.diagnostic.open_float, "Diagnostics float")
        map("n", "[d",         vim.diagnostic.goto_prev,  "Prev diagnostic")
        map("n", "]d",         vim.diagnostic.goto_next,  "Next diagnostic")

        -- Inlay hints toggle (Neovim 0.10+)
        if vim.lsp.inlay_hint then
            map("n", "<leader>uh", function()
                vim.lsp.inlay_hint.enable(
                    not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
                    { bufnr = bufnr }
                )
            end, "Toggle inlay hints")
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end
    end,
})

--------------------------
-- Mason: install / manage LSP server binaries
--------------------------
local ok_mason, mason = pcall(require, "mason")
if not ok_mason then
    vim.notify("mason.nvim not yet installed — run :lua vim.pack.update()", vim.log.levels.WARN)
    return
end

mason.setup({
    ui = {
        border = "rounded",
        icons = {
            package_installed   = "✓",
            package_pending     = "➜",
            package_uninstalled = "✗",
        },
    },
})

-- mason-lspconfig bridges Mason package names ↔ lspconfig server names.
-- ensure_installed lists servers Mason should auto-install if missing.
local ok_mlsp, mason_lspconfig = pcall(require, "mason-lspconfig")
if ok_mlsp then
    mason_lspconfig.setup({
        ensure_installed = {
            "basedpyright",
            "ruff",
            "lua_ls",
            "clangd",
            "neocmake",
            "rust_analyzer",
            "gopls",
        },
        automatic_installation = true,
    })
end

--------------------------
-- Lang-specific servers
--------------------------
local ok_lspcfg = pcall(require, "lspconfig")
if not ok_lspcfg then return end

require("lang.c")
require("lang.lua_ls")
require("lang.python")
require("lang.rust")
require("lang.go")
