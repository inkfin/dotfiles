-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

------------------------------
-- Setup backup and undo paths
------------------------------
local is_directory_exists = function(dir)
    return vim.fn.empty(vim.fn.glob(dir)) == 0
end

local backup_path = vim.fn.stdpath("data") .. "/tmp/backup"
local undo_path = vim.fn.stdpath("data") .. "/tmp/undo"

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

-----------------------
-- Basic editor configs
-----------------------
vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.g.tex_flavor = "latex"

local opt = vim.opt
local indent = 4

opt.autowrite = true -- Enable auto write
opt.backup = true
opt.clipboard = "unnamedplus" -- Sync with system clipboard
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
opt.scrolloff = 4 -- Lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }
opt.shiftround = true -- Round indent
opt.shiftwidth = indent -- Size of an indent
opt.shortmess:append({ W = true, I = true, c = true })
opt.showmode = false -- Dont show mode since we have a statusline
opt.sidescrolloff = 8 -- Columns of context
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.spell = true -- Spell check
opt.spelllang = { "en", "cjk" } -- Set language: English and Chinese
opt.spelloptions = "camel" -- Enable camel case
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current
opt.tabstop = indent -- Number of spaces tabs count for
opt.termguicolors = true -- True color support
opt.timeoutlen = 150 -- Set wait time
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width
opt.wrap = true -- Enable line wrap

if vim.fn.has("nvim-0.9.0") == 1 then
    opt.splitkeep = "screen"
    opt.shortmess:append({ C = true })
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

-----------------------------
-- Platform Specific Settings
-----------------------------

local function file_exists(name)
    local f = io.open(name, "r")
    return f ~= nil and io.close(f)
end

--- MacOS ---
if vim.fn.has("mac") == 1 then
    -- specify the python parser path
    local intel_brew = "/usr/local/bin/python3"
    local arm_brew = "/opt/homebrew/bin/python3"
    if file_exists(arm_brew) then
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
elseif vim.fn.has("win32") then
    vim.g.python3_host_prog = "$HOME/miniconda3/current/python"
end

require("utils.func")
