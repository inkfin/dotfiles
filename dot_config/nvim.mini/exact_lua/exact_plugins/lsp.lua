-- ~/.config/nvim.mini/lua/plugins/lsp.lua
-- LSP framework: diagnostics UI + global keymaps via LspAttach
-- Individual servers live in lua/lang/*.lua and own both their Mason install
-- entries and server-specific setup.

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
        or vim.wo[vim.fn.bufwinid(bufnr)].diff
end

local function disable_buffer_lsp_features(bufnr)
    vim.diagnostic.enable(false, { bufnr = bufnr })
    pcall(vim.lsp.inlay_hint.enable, false, { bufnr = bufnr })
    pcall(vim.lsp.document_color.enable, false, { bufnr = bufnr })
    pcall(vim.lsp.semantic_tokens.enable, false, { bufnr = bufnr })

    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        pcall(vim.lsp.codelens.clear, client.id, bufnr)
    end
end

local function constrain_disabled_buffer_clients(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) or not lsp_disabled(bufnr) then
        return
    end

    -- Leaving clients attached avoids Neovim 0.12 diff-mode changetracking
    -- crashes during :diffput / :diffget, while still turning off the costly
    -- UI features that make diff buffers noisy and slow.
    disable_buffer_lsp_features(bufnr)
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
local lsp_ui = ok_local and local_cfg.lsp or {}
local ok_fzf, fzf = pcall(require, "fzf-lua")
local ok_trouble, trouble = pcall(require, "trouble")

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

local function open_list_ui(mode)
    if ok_trouble then
        local ok_open, err = pcall(trouble.open, { mode = mode, focus = true })
        if ok_open then return end
        vim.notify(err, vim.log.levels.WARN)
    end

    if mode == "loclist" then
        vim.cmd.lopen()
    else
        vim.cmd("botright copen")
    end
end

local function list_handler(mode)
    return function(list)
        if mode == "loclist" then
            vim.fn.setloclist(0, {}, " ", list)
        else
            vim.fn.setqflist({}, " ", list)
        end
        open_list_ui(mode)
    end
end

local function show_lsp_references()
    show_lsp_picker("lsp_references", function()
        -- Keep references window-local via loclist, but surface the list
        -- through Trouble when it is available instead of the native list UI.
        vim.lsp.buf.references(nil, { on_list = list_handler("loclist") })
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
            constrain_disabled_buffer_clients(ev.buf)
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
            require("format").format({ async = true, bufnr = bufnr })
        end, "Format buffer")

        -- Diagnostics
        map("n", "<leader>cd", vim.diagnostic.open_float,                        "Diagnostics float")
        map("n", "[d",         function() vim.diagnostic.jump({ count = -1 }) end, "Prev diagnostic")
        map("n", "]d",         function() vim.diagnostic.jump({ count =  1 }) end, "Next diagnostic")
    end,
})

vim.api.nvim_create_autocmd({ "BufWinEnter", "FileType" }, {
    group = vim.api.nvim_create_augroup("nvim_mini_lsp_heavy_buffers", { clear = true }),
    callback = function(ev)
        -- Covers reused clients and buffers that become `bigfile` on FileType.
        constrain_disabled_buffer_clients(ev.buf)
    end,
})

vim.api.nvim_create_autocmd("OptionSet", {
    group = vim.api.nvim_create_augroup("nvim_mini_lsp_diff_toggle", { clear = true }),
    pattern = "diff",
    callback = function()
        -- Diff mode can be toggled after LSP is already attached.
        constrain_disabled_buffer_clients(vim.api.nvim_get_current_buf())
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

-- Keep non-LSP Mason tools here too so a normal startup can bootstrap the
-- formatter binaries that conform expects, without requiring a manual
-- `:MasonInstall` later.
local function ensure_mason_packages(pkg_names)
    local ok_registry, registry = pcall(require, "mason-registry")
    if not ok_registry then return end

    local function install_missing()
        local seen = {}
        for _, pkg_name in ipairs(pkg_names) do
            if not seen[pkg_name] then
                seen[pkg_name] = true
                local ok_pkg, pkg = pcall(registry.get_package, pkg_name)
                if ok_pkg and not pkg:is_installed() then
                    pkg:install()
                end
            end
        end
    end

    if registry.refresh then
        registry.refresh(vim.schedule_wrap(install_missing))
    else
        install_missing()
    end
end

--------------------------
-- Lang-specific specs
--------------------------
local ok_lspcfg = pcall(require, "lspconfig")
if not ok_lspcfg then return end

local ok_lang, lang_registry = pcall(require, "lang")
if not ok_lang then return end

-- Collect install requirements first, then run per-language setup after Mason
-- has been configured. This keeps install metadata near each language file
-- while avoiding language-specific wiring in this plugin module.
local lang_specs = lang_registry.collect()

local ok_mlsp, mason_lspconfig = pcall(require, "mason-lspconfig")
if ok_mlsp then
    mason_lspconfig.setup({
        -- Only server ids that mason-lspconfig understands belong here.
        ensure_installed = lang_specs.ensure_servers,
        automatic_installation = false,
    })
end

-- Install raw Mason package names only after mason.setup() has initialized its
-- data dir/PATH handling. This includes non-LSP tools like prettierd/taplo,
-- which `nvim.mini` needs for JSON/TOML formatting.
ensure_mason_packages(vim.list_extend(vim.deepcopy(lang_specs.ensure_packages), {
    "prettierd",
    "taplo",
}))

-- Run actual server/plugin setup only after install collection is done. The
-- setup calls stay in `lang/*.lua`, so adding a new language is mostly local.
for _, spec in ipairs(lang_specs.loaded) do
    if type(spec.setup) == "function" then
        spec.setup()
    end
end
