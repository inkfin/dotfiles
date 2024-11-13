-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

------------------------------
-- Setup backup and undo paths
------------------------------
-- https://vimdoc.sourceforge.net/htmldoc/usr_21.html#21.3
vim.go.viminfo = "!,'1000,f1,<500,s10,h"
vim.go.encoding = "utf-8"

local is_directory_exists = function(dir)
    return vim.fn.empty(vim.fn.glob(dir)) == 0
end

local backup_path = vim.fn.stdpath("data") .. "/cache/backup"
local undo_path = vim.fn.stdpath("data") .. "/cache/undo"

if not is_directory_exists(backup_path) then
    os.execute(backup_path)
end
if not is_directory_exists(undo_path) then
    os.execute(undo_path)
end

vim.go.backupdir = backup_path
vim.go.directory = backup_path

if vim.fn.has("persistent_undo") == 1 then
    vim.bo.undofile = true
    vim.go.undodir = undo_path
end

if vim.fn.has("nvim") == 1 then
    vim.cmd([[ let $GIT_EDITOR = 'nvr -cc split --remote-wait' ]])
end

-----------------------
-- Basic editor configs
-----------------------
vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.g.tex_flavor = "latex"

-- Enable LazyVim auto format
vim.g.autoformat = true

vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

-- LazyVim root dir detection
-- Each entry can be:
-- * the name of a detector function like `lsp` or `cwd`
-- * a pattern or array of patterns like `.git` or `lua`.
-- * a function with signature `function(buf) -> string|string[]`
vim.g.root_spec =
    { "lsp", { ".git", "lua", "node_modules", "Makefile", ".vscode", ".root", ".vim", ".vs", ".idea" }, "cwd" }

local opt = vim.opt
local indent = 4

opt.autowrite = true -- Enable auto write
opt.backup = true
-- only set clipboard if not in ssh, to make sure the OSC 52
-- integration works automatically. Requires Neovim >= 0.10.0
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 3 -- Hide * markup for bold and italic
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.cursorline = true -- Enable highlighting of the current line
opt.expandtab = true -- Use spaces instead of tabs
opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true -- Ignore case
opt.inccommand = "nosplit" -- preview incremental substitute
opt.laststatus = 0
opt.list = true -- Show some invisible characters (tabs...
opt.mouse = "a" -- Enable mouse mode
opt.number = true -- Print line number
opt.pumblend = 10 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.relativenumber = true -- Relative line numbers
opt.scrolloff = 5 -- Lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true -- Round indent
opt.shiftwidth = indent -- Size of an indent
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false -- Dont show mode since we have a statusline
opt.sidescrolloff = 8 -- Columns of context
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.smarttab = true
opt.spell = true -- Spell check
opt.spelllang = { "en", "cjk" } -- Set language: English and Chinese
opt.spelloptions = "camel" -- Enable camel case
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current
opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]
opt.tabstop = indent -- Number of spaces tabs count for
opt.termguicolors = true -- True color support
opt.timeoutlen = vim.g.vscode and 1000 or 300 -- Lower than default (1000) to quickly trigger which-key
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width
opt.wrap = true -- Enable line wrap
opt.fillchars = {
    foldopen = "",
    foldclose = "",
    fold = "⸱",
    -- fold = " ",
    foldsep = " ",
    diff = "╱",
    eob = " ",
}

-- Folding
if vim.fn.has("nvim-0.10") == 1 then
    opt.smoothscroll = true
    opt.foldexpr = "v:lua.require'lazyvim.util'.ui.foldexpr()"
    opt.foldmethod = "expr"
    opt.foldtext = ""
else
    opt.foldmethod = "indent"
    opt.foldtext = "v:lua.require'lazyvim.util'.ui.foldtext()"
end

-- HACK: causes freezes on <= 0.9, so only enable on >= 0.10 for now
if vim.fn.has("nvim-0.10") == 1 then
    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
else
    vim.opt.foldmethod = "indent"
end
-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0

vim.g.neoterm_autoscroll = 1
vim.g.terminal_color_0 = "#000000"
vim.g.terminal_color_1 = "#FF5555"
vim.g.terminal_color_2 = "#50FA7B"
vim.g.terminal_color_3 = "#F1FA8C"
vim.g.terminal_color_4 = "#BD93F9"
vim.g.terminal_color_5 = "#FF79C6"
vim.g.terminal_color_6 = "#8BE9FD"
vim.g.terminal_color_7 = "#BFBFBF"
vim.g.terminal_color_8 = "#4D4D4D"
vim.g.terminal_color_9 = "#FF6E67"
vim.g.terminal_color_10 = "#5AF78E"
vim.g.terminal_color_11 = "#F4F99D"
vim.g.terminal_color_12 = "#CAA9FA"
vim.g.terminal_color_13 = "#FF92D0"
vim.g.terminal_color_14 = "#9AEDFE"

vim.g.zen_width = 100
vim.g.zen_height = 1

-----------------------------
-- Platform Specific Settings
-----------------------------

--- MacOS ---
if vim.fn.has("mac") == 1 then
    -- specify the python parser path
    local intel_brew = "/usr/local/bin/python3"
    local arm_brew = "/opt/homebrew/bin/python3"
    if vim.g.file_exists(arm_brew) then
        vim.g.python3_host_prog = arm_brew
    else
        vim.g.python3_host_prog = intel_brew
    end

    -- " === ybian/smartim ===
    -- "    some people reported that it is slow while editing with vim-multiple-cursors, to fix this, put this in .vimrc:
    -- let g:smartim_default = 'com.apple.keylayout.ABC'
    -- function! Multiple_cursors_before()
    --   let g:smartim_disable = 1
    -- endfunction
    -- function! Multiple_cursors_after()
    --   unlet g:smartim_disable
    -- endfunction
elseif vim.fn.has("win32") == 1 and vim.fn.has("wsl") == 0 then
    vim.g.python3_host_prog = "$HOME/scoop/apps/python/current/python.EXE"

    -- change default shell to powershell
    vim.go.shell = "pwsh"
    --- Disable profile to accelerate powershell startup;
    --- I need my custom function to focus different windows, so execute that ps1 file
    vim.go.shellcmdflag = "-NoLogo -NonInteractive -NoProfile -ExecutionPolicy RemoteSigned "
        .. "-Command . $HOME/Documents/PowerShell/Utilities.ps1; "
    vim.go.shellquote = "" -- !<quote>command<quote>
    vim.go.shellxquote = ""
end

-- clipboard settings (:h clipboard-wsl)
if vim.fn.has("wsl") == 1 then
    if vim.fn.executable("win32yank.exe") == 1 then
        vim.g.clipboard = {
            name = "win32yank-wsl",
            copy = {
                ["+"] = "win32yank.exe -i --crlf",
                ["*"] = "win32yank.exe -i --crlf",
            },
            paste = {
                ["+"] = "win32yank.exe -o --lf",
                ["*"] = "win32yank.exe -o --lf",
            },
            cache_enabled = true,
        }
    else
        vim.g.clipboard = {
            name = "WslClipboard",
            copy = {
                ["+"] = "clip.exe",
                ["*"] = "clip.exe",
            },
            paste = {
                ["+"] = 'powershell.exe -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
                ["*"] = 'powershell.exe -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
            },
            cache_enabled = 0,
        }
    end
end

--- mouse menus
vim.cmd([[
    aunmenu PopUp.How-to\ disable\ mouse
    aunmenu PopUp.-1-
]])

--- Neovide Configurations
if vim.g.neovide then
    vim.o.guifont = "FiraCode Nerd Font Mono:h16"
    vim.o.linespace = 0 -- Controls spacing between lines, may also be negative.
    vim.g.neovide_scale_factor = 1.0

    -- Window Blur (Currently macOS only)
    if vim.fn.has("mac") == 1 then
        vim.g.neovide_transparency = 0.6
        vim.g.neovide_window_blurred = true
    else
        vim.g.neovide_transparency = 0.8
    end

    -- Windows configuration
    if vim.fn.has("win32") == 1 then
        vim.g.neovide_fullscreen = true
        vim.g.neovide_padding_top = 10
        vim.g.neovide_padding_bottom = 10
        vim.g.neovide_padding_right = 10
        vim.g.neovide_padding_left = 10
    end

    -- Floating shadow
    -- since 0.12.0
    vim.g.neovide_floating_shadow = true
    vim.g.neovide_floating_z_height = 10
    vim.g.neovide_light_angle_degrees = 45
    vim.g.neovide_light_radius = 5

    -- Floating Blur Amount
    vim.g.neovide_floating_blur_amount_x = 2.0
    vim.g.neovide_floating_blur_amount_y = 2.0

    vim.g.neovide_hide_mouse_when_typing = true
    vim.g.neovide_underline_automatic_scaling = true
    vim.g.neovide_confirm_quit = true
    vim.g.neovide_input_macos_option_key_is_meta = "only_left"

    -- Animations
    vim.g.neovide_scroll_animation_length = 0.3
    vim.g.neovide_cursor_vfx_mode = "sonicboom"
end
