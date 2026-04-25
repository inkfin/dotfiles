-- ~/.config/nvim.mini/lua/options.lua
-- Core editor settings (ported from nvim.lazyvim/lua/config/options.lua)

vim.g.mapleader      = " "
vim.g.maplocalleader = ","

-- When running inside a Neovim terminal, forward editor calls to the outer
-- session instead of opening a nested nvim. vim.env.NVIM is the parent socket,
-- set automatically by Neovim in every :terminal it spawns.
-- EDITOR/VISUAL are needed by yazi's opener (its default `{ run = "$EDITOR %s" }`).
-- GIT_EDITOR covers `git commit` and similar from the bottom shell.
if vim.fn.has("nvim") == 1 and vim.env.NVIM then
    local remote = ("nvim --server '%s' --remote-wait-silent"):format(vim.env.NVIM)
    vim.env.EDITOR     = remote
    vim.env.VISUAL     = remote
    vim.env.GIT_EDITOR = remote
end

local opt = vim.opt
local indent = 4

--------------------------
-- Backup & undo paths
--------------------------
local function dir_exists(dir)
    return vim.fn.isdirectory(vim.fs.normalize(dir)) == 1
end

local backup_path = vim.fn.stdpath("data") .. "/backup"
local undo_path   = vim.fn.stdpath("data") .. "/undo"

for _, dir in ipairs({ backup_path, undo_path }) do
    if not dir_exists(dir) then
        vim.fn.mkdir(dir, "p")
    end
end

opt.backupdir = backup_path
opt.directory  = backup_path
opt.undodir    = undo_path
opt.undofile   = true
opt.undolevels = 10000
-- Persist marks, command history, registers, and file positions across
-- Neovim sessions.
opt.shada      = "!,'100,<50,s10,h"

--------------------------
-- Basic settings
--------------------------
opt.encoding    = "utf-8"
opt.autowrite   = true
opt.backup      = true
opt.confirm     = true          -- ask before quitting unsaved buffer
opt.exrc        = true          -- read project-local .nvim.lua/.exrc files
opt.updatetime  = 200
opt.timeoutlen  = 300

-- Clipboard: skip in SSH so OSC 52 works
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"

--------------------------
-- UI
--------------------------
opt.number         = true
opt.relativenumber = true
opt.cursorline     = true
opt.signcolumn     = "yes"
opt.showmode       = false      -- statusline handles this
opt.termguicolors  = true
opt.pumheight      = 10
opt.pumblend       = 10
opt.scrolloff      = 5
opt.sidescrolloff  = 8
opt.winminwidth    = 5
opt.laststatus     = 2

opt.list = true
opt.listchars = { tab = "→ ", trail = "·", nbsp = "+" }
vim.opt.listchars:append("space:·")

opt.fillchars = {
    foldopen  = "▾",
    foldclose = "▸",
    fold      = " ",
    foldsep   = " ",
    diff      = "╱",
    eob       = " ",
}

--------------------------
-- Indentation
--------------------------
opt.expandtab   = true
opt.shiftwidth  = indent
opt.tabstop     = indent
opt.shiftround  = true
opt.smartindent = true
opt.smarttab    = true

--------------------------
-- Search
--------------------------
opt.ignorecase  = true
opt.smartcase   = true
opt.inccommand  = "nosplit"
opt.grepformat  = "%f:%l:%c:%m"
opt.grepprg     = "rg --vimgrep"

--------------------------
-- Folding (Treesitter-based on 0.10+)
--------------------------
if vim.fn.has("nvim-0.10") == 1 then
    opt.smoothscroll = true
    opt.foldmethod   = "expr"
    opt.foldexpr     = "v:lua.vim.treesitter.foldexpr()"
    opt.foldtext     = ""
    opt.foldlevel    = 99     -- all folds open by default
    opt.foldlevelstart = 99   -- start editing with all folds open
else
    opt.foldmethod = "indent"
end

--------------------------
-- Splits & misc
--------------------------
opt.splitbelow   = true
opt.splitright   = true
opt.wrap         = true
opt.formatoptions = "jcroqlnt"
opt.shortmess:append({ W = true, c = true, C = true })
opt.completeopt  = "menu,menuone,noselect"
opt.mouse        = "a"
opt.conceallevel = 3
opt.spell        = false        -- enable per-buffer as needed
opt.wildmode     = "longest:full,full"

--------------------------
-- Terminal colours (Dracula palette)
--------------------------
vim.g.terminal_color_0  = "#000000"
vim.g.terminal_color_1  = "#FF5555"
vim.g.terminal_color_2  = "#50FA7B"
vim.g.terminal_color_3  = "#F1FA8C"
vim.g.terminal_color_4  = "#BD93F9"
vim.g.terminal_color_5  = "#FF79C6"
vim.g.terminal_color_6  = "#8BE9FD"
vim.g.terminal_color_7  = "#BFBFBF"
vim.g.terminal_color_8  = "#4D4D4D"
vim.g.terminal_color_9  = "#FF6E67"
vim.g.terminal_color_10 = "#5AF78E"
vim.g.terminal_color_11 = "#F4F99D"
vim.g.terminal_color_12 = "#CAA9FA"
vim.g.terminal_color_13 = "#FF92D0"
vim.g.terminal_color_14 = "#9AEDFE"

--------------------------
-- Platform-specific
--------------------------

-- Windows (non-WSL)
if vim.fn.has("win32") == 1 and vim.fn.has("wsl") == 0 then
    vim.go.shell        = "pwsh"
    vim.go.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
        .. " [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();"
        .. " $PSDefaultParameterValues['Out-File:Encoding']='utf8';"
        .. " $PSStyle.OutputRendering = 'PlainText';"
    vim.go.shellpipe   = "> %s 2>&1"
    vim.go.shellquote  = ""
    vim.go.shellxquote = ""
end

-- WSL clipboard
if vim.fn.has("wsl") == 1 then
    if vim.fn.executable("win32yank.exe") == 1 then
        vim.g.clipboard = {
            name  = "win32yank-wsl",
            copy  = { ["+"] = "win32yank.exe -i --crlf", ["*"] = "win32yank.exe -i --crlf" },
            paste = { ["+"] = "win32yank.exe -o --lf",   ["*"] = "win32yank.exe -o --lf" },
            cache_enabled = true,
        }
    else
        vim.g.clipboard = {
            name  = "WslClipboard",
            copy  = { ["+"] = "clip.exe", ["*"] = "clip.exe" },
            paste = {
                ["+"] = 'powershell.exe -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
                ["*"] = 'powershell.exe -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
            },
            cache_enabled = 0,
        }
    end
end

-- Neovide GUI
if vim.g.neovide then
    local guifont     = "FantasqueSansM Nerd Font Mono"
    local guifontsize = 16

    function _G.AdjustFontSize(amount)
        guifontsize = guifontsize + amount
        vim.o.guifont = guifont .. ":h" .. guifontsize
    end
    AdjustFontSize(0)

    vim.keymap.set("n", "<D-=>", function() AdjustFontSize(1)  end, { noremap = true, silent = true })
    vim.keymap.set("n", "<D-->", function() AdjustFontSize(-1) end, { noremap = true, silent = true })

    vim.g.neovide_opacity               = 0.8
    vim.g.neovide_normal_opacity        = 0.8
    vim.g.neovide_scroll_animation_length = 0.15
    vim.g.neovide_cursor_vfx_mode       = "sonicboom"
    vim.g.neovide_floating_shadow       = true
    vim.g.neovide_floating_z_height     = 10
    vim.g.neovide_floating_blur_amount_x = 2.0
    vim.g.neovide_floating_blur_amount_y = 2.0
    vim.g.neovide_hide_mouse_when_typing = true
    vim.g.neovide_confirm_quit          = true
    vim.g.neovide_input_macos_option_key_is_meta = "only_left"

    if vim.fn.has("mac") == 1 then
        vim.g.neovide_window_blurred = true
    end
    if vim.fn.has("win32") == 1 then
        vim.g.neovide_padding_top    = 10
        vim.g.neovide_padding_bottom = 10
        vim.g.neovide_padding_right  = 10
        vim.g.neovide_padding_left   = 10
    end
end
