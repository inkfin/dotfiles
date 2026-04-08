-- ~/.config/nvim.mini/lua/autocmds.lua
-- Merged from:
--   LazyVim defaults (lazyvim/config/autocmds.lua)
--   Custom overrides (nvim.lazyvim/lua/config/autocmds.lua)

local cfg = require("config")
local ok_local, local_cfg = pcall(require, "local")
local_cfg = ok_local and local_cfg or {}

local function augroup(name)
    return vim.api.nvim_create_augroup("nvim_mini_" .. name, { clear = true })
end

--------------------------
-- From LazyVim defaults
--------------------------

-- Reload file when it changes outside Neovim
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = augroup("checktime"),
    callback = function()
        if vim.o.buftype ~= "nofile" then
            vim.cmd("checktime")
        end
    end,
})

-- Highlight yanked text briefly
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup("highlight_yank"),
    callback = function()
        (vim.hl or vim.highlight).on_yank()
    end,
})

-- Equalize splits when Neovim is resized
vim.api.nvim_create_autocmd("VimResized", {
    group = augroup("resize_splits"),
    callback = function()
        local current_tab = vim.fn.tabpagenr()
        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. current_tab)
    end,
})

-- Return to last cursor position when reopening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup("last_loc"),
    callback = function(event)
        local exclude = { "gitcommit" }
        local buf = event.buf
        if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].nvim_mini_last_loc then
            return
        end
        vim.b[buf].nvim_mini_last_loc = true
        local mark = vim.api.nvim_buf_get_mark(buf, '"')
        local lcount = vim.api.nvim_buf_line_count(buf)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Close certain utility buffers with <q>
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("close_with_q"),
    pattern = {
        "PlenaryTestPopup", "checkhealth", "dap-float", "dbout",
        "gitsigns-blame", "grug-far", "help", "lspinfo",
        "neotest-output", "neotest-output-panel", "neotest-summary",
        "notify", "qf", "spectre_panel", "startuptime", "tsplayground",
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.schedule(function()
            vim.keymap.set("n", "q", function()
                vim.cmd("close")
                pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
            end, { buffer = event.buf, silent = true, desc = "Quit buffer" })
        end)
    end,
})

-- Unlist man pages opened inline
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("man_unlisted"),
    pattern = { "man" },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
    end,
})

-- Wrap + spell in prose filetypes
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("wrap_spell"),
    pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = true
    end,
})

-- No conceal in JSON
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("json_conceal"),
    pattern = { "json", "jsonc", "json5" },
    callback = function()
        vim.opt_local.conceallevel = 0
    end,
})

-- Auto-create intermediate directories on save
vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup("auto_create_dir"),
    callback = function(event)
        if event.match:match("^%w%w+:[\\/][\\/]") then return end
        local file = vim.uv.fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
})

--------------------------
-- Custom autocmds
--------------------------

vim.api.nvim_create_autocmd("VimEnter", {
    group = augroup("root_lcd"),
    callback = function()
        local root = vim.fs.root(0, cfg.root_patterns)
        if root then
            vim.cmd("lcd " .. root)
        end
    end,
})

-- Don't auto-continue comments on newline (o/O/Enter)
vim.api.nvim_create_autocmd("BufEnter", {
    group = augroup("no_auto_comment"),
    callback = function()
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
})

-- Per-filetype indent widths (table lives in config.lua)
local function settab(n)
    vim.opt_local.tabstop     = n
    vim.opt_local.shiftwidth  = n
    vim.opt_local.softtabstop = n
end

do
    -- Build pattern lists from cfg.indent map, grouped by width
    local by_width = {}
    for ft, w in pairs(cfg.indent) do
        by_width[w] = by_width[w] or {}
        table.insert(by_width[w], ft)
    end
    for width, fts in pairs(by_width) do
        vim.api.nvim_create_autocmd("FileType", {
            group   = augroup("indent_" .. width),
            pattern = fts,
            callback = function() settab(width) end,
        })
    end
end

-- Format is always manual — disable autoformat on every buffer.
-- Flip cfg.autoformat = true in config.lua to re-enable globally.
vim.g.autoformat = cfg.autoformat
vim.api.nvim_create_autocmd("BufEnter", {
    group = augroup("autoformat_state"),
    callback = function()
        if vim.b.autoformat == nil then
            vim.b.autoformat = vim.g.autoformat
        end
    end,
})

-- Template file insertion for new buffers
local template_dirs = {
    vim.fn.expand("$HOME/.config/nvim/template"),
    vim.fn.expand("$HOME/template"),
    vim.fn.expand("$HOME/template/cmake_project"),
    vim.fn.expand("$HOME/template/make_project"),
}

local function find_template(filepath)
    local filename = vim.fn.fnamemodify(filepath, ":t")
    local ext      = vim.fn.fnamemodify(filepath, ":e")
    for _, dir in ipairs(template_dirs) do
        local by_name = dir .. "/" .. filename
        if vim.fn.filereadable(by_name) == 1 then return by_name end
        local by_ext = dir .. "/template." .. ext
        if vim.fn.filereadable(by_ext) == 1 then return by_ext end
    end
end

vim.api.nvim_create_autocmd("BufNewFile", {
    group = augroup("template"),
    callback = function(event)
        local tmpl = find_template(event.match)
        if tmpl then
            vim.cmd("silent! 0r " .. tmpl)
        end
    end,
})

-- Run chezmoi apply when saving a dotfile managed by chezmoi
if not vim.wo.diff then
    vim.api.nvim_create_autocmd("BufWritePost", {
        group = augroup("chezmoi"),
        pattern = vim.fn.expand("~/.local/share/chezmoi/") .. "*",
        callback = function(event)
            vim.system({ "chezmoi", "apply", "--source-path", event.match })
        end,
    })
end

-- No conceal in markdown
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("markdown_conceal"),
    pattern = { "markdown" },
    callback = function()
        vim.wo.conceallevel = 0
    end,
})

-- Fold + conceal settings for Neorg
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("norg_settings"),
    pattern = { "norg" },
    callback = function()
        vim.wo.foldlevel    = 99
        vim.wo.conceallevel = 2
    end,
})

-- Keep LspInlayHint readable; optionally enforce transparent background
vim.api.nvim_create_autocmd("ColorScheme", {
    group = augroup("inlay_hint_hl"),
    pattern = "*",
    callback = function()
        vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#87744d", bg = "NONE" })
        if local_cfg.transparent then
            vim.api.nvim_set_hl(0, "Normal",      { bg = "NONE", ctermbg = "NONE" })
            vim.api.nvim_set_hl(0, "NormalNC",    { bg = "NONE", ctermbg = "NONE" })
            vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE", ctermbg = "NONE" })
            vim.api.nvim_set_hl(0, "SignColumn",  { bg = "NONE", ctermbg = "NONE" })
            vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE", ctermbg = "NONE" })
        end
    end,
})
