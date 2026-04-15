-- ~/.config/nvim.mini/lua/plugins/lsp.lua
-- LSP framework: diagnostics UI + global keymaps via LspAttach
-- Individual servers live in lua/lang/*.lua
-- Mason installs missing server binaries automatically.

require("pack").add({
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/williamboman/mason.nvim",
    "https://github.com/williamboman/mason-lspconfig.nvim",
    "https://github.com/chrisgrieser/nvim-lsp-endhints",
    "https://github.com/SmiteshP/nvim-navic",
})

local function lsp_disabled(bufnr)
    -- Big files are tagged by snacks.nvim as filetype=bigfile.
    -- Diff buffers stay read-focused, so keep LSP off there too.
    return vim.b[bufnr].lsp_disabled
        or vim.bo[bufnr].filetype == "bigfile"
        or vim.wo.diff
end

local function stop_heavy_buffer_clients(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) or not lsp_disabled(bufnr) then
        return
    end

    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        pcall(vim.lsp.buf_detach_client, bufnr, client.id)
        if vim.tbl_isempty(client.attached_buffers or {}) then
            client:stop()
        end
    end

    vim.diagnostic.enable(false, { bufnr = bufnr })
end

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

local ok_navic, navic = pcall(require, "nvim-navic")
if ok_navic then
    navic.setup({
        highlight = false,
        separator = " > ",
        depth_limit = 5,
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

local ok_local, local_cfg = pcall(require, "local")
local lang = ok_local and local_cfg.lang or {}
local lsp_ui = ok_local and local_cfg.lsp or {}
local ok_fzf, fzf = pcall(require, "fzf-lua")
local function enabled(key) return lang[key] == true end

local function use_fzf_lua_lsp_ui()
    return lsp_ui.references == "fzf-lua"
end

local function show_lsp_picker(fzf_name, fallback, opts)
    if use_fzf_lua_lsp_ui() then
        local picker = ok_fzf and fzf[fzf_name]
        if type(picker) == "function" then
            picker(opts or {})
            return
        end
    end
    fallback()
end

local function show_lsp_references()
    show_lsp_picker("lsp_references", function()
        -- Default references go to quickfix; force loclist for the builtin path.
        vim.lsp.buf.references(nil, { loclist = true })
    end, {
        ignore_current_line = true,
        jump1 = true,
    })
end

local function show_lsp_definition()
    show_lsp_picker("lsp_definitions", vim.lsp.buf.definition)
end

local function show_lsp_declaration()
    show_lsp_picker("lsp_declarations", vim.lsp.buf.declaration)
end

local function show_lsp_implementation()
    show_lsp_picker("lsp_implementations", vim.lsp.buf.implementation)
end

local function show_lsp_type_definition()
    show_lsp_picker("lsp_typedefs", vim.lsp.buf.type_definition)
end

--------------------------
-- Global on_attach via LspAttach autocommand
--------------------------
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("nvim_mini_lsp_attach", { clear = true }),
    callback = function(ev)
        -- If a client still attaches in a heavy buffer, drop it immediately.
        if lsp_disabled(ev.buf) then
            stop_heavy_buffer_clients(ev.buf)
            return
        end

        local bufnr = ev.buf
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        local map = function(mode, lhs, rhs, desc, opts)
            vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", {
                buffer = bufnr,
                silent = true,
                desc = desc,
            }, opts or {}))
        end

        if ok_navic and client and client:supports_method("textDocument/documentSymbol") then
            pcall(navic.attach, client, bufnr)
        end

        -- Navigation
        map("n", "gd",  show_lsp_definition,      "Go to definition")
        map("n", "gD",  show_lsp_declaration,     "Go to declaration")
        map("n", "gi",  show_lsp_implementation,  "Go to implementation")
        map("n", "gr",  show_lsp_references,      "References", { nowait = true })
        map("n", "gy",  show_lsp_type_definition, "Go to type definition")

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

vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType" }, {
    group = vim.api.nvim_create_augroup("nvim_mini_lsp_heavy_buffers", { clear = true }),
    callback = function(ev)
        -- Covers reused clients and buffers that become `bigfile` on FileType.
        stop_heavy_buffer_clients(ev.buf)
    end,
})

vim.api.nvim_create_autocmd("OptionSet", {
    group = vim.api.nvim_create_augroup("nvim_mini_lsp_diff_toggle", { clear = true }),
    pattern = "diff",
    callback = function()
        -- Diff mode can be toggled after LSP is already attached.
        stop_heavy_buffer_clients(vim.api.nvim_get_current_buf())
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
