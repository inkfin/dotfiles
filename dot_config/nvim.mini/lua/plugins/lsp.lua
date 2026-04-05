-- ~/.config/nvim.mini/lua/plugins/lsp.lua
-- LSP framework: diagnostics UI + global keymaps via LspAttach
-- Individual servers live in lua/lang/*.lua
-- Mason installs missing server binaries automatically.

require("pack").add({
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/williamboman/mason.nvim",
    "https://github.com/williamboman/mason-lspconfig.nvim",
    "https://github.com/chrisgrieser/nvim-lsp-endhints",
})

--------------------------
-- nvim-lsp-endhints
--------------------------
local ok_endhints, endhints = pcall(require, "lsp-endhints")
if ok_endhints then
    endhints.setup({
        icons = {
            type      = "󰜁 ",
            parameter = "󰏪 ",
        },
        label = {
            truncateAtChars = 20,
            padding         = 1,
        },
    })
end

--------------------------
-- Diagnostics UI
--------------------------
vim.diagnostic.config({
    virtual_text = { prefix = "●" },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "󰅚",
            [vim.diagnostic.severity.WARN]  = "󰀦",
            [vim.diagnostic.severity.INFO]  = "󰋽",
            [vim.diagnostic.severity.HINT]  = "󰌶",
        },
    },
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
        map("n", "<leader>cd", vim.diagnostic.open_float,                    "Diagnostics float")
        map("n", "[d",         function() vim.diagnostic.jump({ count = -1 }) end, "Prev diagnostic")
        map("n", "]d",         function() vim.diagnostic.jump({ count =  1 }) end, "Next diagnostic")
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
        keymaps = {
            toggle_help = "?",   -- default g? conflicts with mini.clue wait-for-next-key
        },
    },
})

--------------------------
-- Lang-specific servers
--------------------------
local ok_lspcfg = pcall(require, "lspconfig")
if not ok_lspcfg then return end

local ok_local, local_cfg = pcall(require, "local")
local lang = ok_local and local_cfg.lang or {}
local function enabled(key) return lang[key] == true end

-- mason-lspconfig bridges Mason package names ↔ lspconfig server names.
-- ensure_installed is filtered by local.lua so Mason only installs what's enabled.
local ok_mlsp, mason_lspconfig = pcall(require, "mason-lspconfig")
if ok_mlsp then
    -- Map local.lua keys → mason-lspconfig server names
    local server_map = {
        c      = { "clangd", "neocmake" },
        lua_ls = { "lua_ls" },
        python = { "basedpyright", "ruff" },
        rust   = { "rust_analyzer" },
        go     = { "gopls" },
        latex  = { "texlab" },
    }
    local ensure = {}
    for key, servers in pairs(server_map) do
        if enabled(key) then
            vim.list_extend(ensure, servers)
        end
    end
    mason_lspconfig.setup({
        ensure_installed    = ensure,
        automatic_installation = false,
    })
end

if enabled("c")      then require("lang.c")       end
if enabled("lua_ls") then require("lang.lua_ls")  end
if enabled("python") then require("lang.python")  end
if enabled("rust")   then require("lang.rust")    end
if enabled("go")     then require("lang.go")      end
if enabled("latex")  then require("lang.latex")   end
