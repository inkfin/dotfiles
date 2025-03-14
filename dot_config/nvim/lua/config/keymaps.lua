-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local Util = require("lazyvim.util")
local wk = require("which-key")

local function map(mode, lhs, rhs, opts)
    local keys = require("lazy.core.handler").handlers.keys
    ---@cast keys LazyKeysHandler
    -- do not create the keymap if a lazy keys handler exists
    if not keys.active[keys.parse({ lhs, mode = mode }).id] then
        opts = opts or {}
        opts.silent = opts.silent ~= false
        if opts.remap and not vim.g.vscode then
            opts.remap = nil
        end
        vim.keymap.set(mode, lhs, rhs, opts)
    end
end

if vim.g.neovide then
    vim.keymap.set("n", "<D-s>", "<CMD>w<CR>", { noremap = true, silent = true }) -- Save
    vim.keymap.set("v", "<D-c>", '"+y', { noremap = true, silent = true }) -- Copy
    vim.keymap.set({ "n", "v" }, "<D-v>", '"+P', { noremap = true, silent = true }) -- Paste normal/visual mode
    vim.keymap.set({"c", "t"}, "<D-v>", "<C-R>+", { noremap = true, silent = true }) -- Paste command mode
    vim.keymap.set("i", "<D-v>", '<ESC>"+pa', { noremap = true, silent = true }) -- Paste insert mode
end

-- handy keymaps
map("n", "dK", ":normal! v0k$d<CR>", { desc = "til prev line", silent = true, noremap = true }) -- delete to start of upper line
map("n", "dJ", ":normal! d$J<CR>", { desc = "til next line", silent = true, noremap = true }) -- delete to end of lower line
map("n", "<leader>J", ":normal! J<CR>", { silent = true, noremap = true })

-- Paste over currently selected text without yanking it
map("v", "p", '"_dP', { silent = true })

-- better movements
-- map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
-- map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({ "n", "x" }, "W", "5w", { silent = true })
map({ "n", "x" }, "E", "5e", { silent = true })
map({ "n", "x" }, "B", "5b", { silent = true })
map({ "v", "o" }, "H", "^", { desc = "Use 'H' as '^'" })
map({ "v", "o" }, "L", "$<left>", { desc = "Use 'L' as '$'" })

-- Move to window using the \ hjkl keys
map("n", "\\h", "<C-w>h", { desc = "Go to left window", remap = true })
map("n", "\\j", "<C-w>j", { desc = "Go to lower window", remap = true })
map("n", "\\k", "<C-w>k", { desc = "Go to upper window", remap = true })
map("n", "\\l", "<C-w>l", { desc = "Go to right window", remap = true })

-- buffers
if Util.has("bufferline.nvim") then
    map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
    map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
    map("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
    map("n", "]b", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
else
    map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
    map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
    map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
    map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
end

-- tabs
map("n", "<leader>ti", "<cmd>tabe<cr>", { desc = "New empty tab" })
map("n", "<leader>td", "<cmd>tabc<cr>", { desc = "Delete tab" })
map("n", "]t", "<cmd>tabn<cr>", { desc = "Next tab" })
map("n", "[t", "<cmd>tabp<cr>", { desc = "Prev tab" })
map("n", "<leader>t<left>", "<cmd>tabm -<cr>", { desc = "Move tab left" })
map("n", "<leader>t<right>", "<cmd>tabm +<cr>", { desc = "Move tab right" })
map("n", "<leader>tmh", "<cmd>-tabm<cr>", { desc = "Move tab left" })
map("n", "<leader>tml", "<cmd>tabm +<cr>", { desc = "Move tab right" })
wk.add({
    { "<leader>tm", group = "+tab +move" },
})

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
map(
    "n",
    "<leader><cr>",
    "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
    { desc = "Redraw / clear hlsearch / diff update" }
)

map({ "n", "x" }, "gw", "", {})

-- expand default hover behavior
function Show_documentation()
    for _, v in pairs({ "vim", "help" }) do
        if v == vim.bo.filetype then
            vim.cmd("h " .. vim.fn.expand("<cword>"))
            return
        end
    end
    vim.lsp.buf.hover()
end

-- configure it here so it is active all the time
map({ "n" }, "K", Show_documentation, { desc = "hover" })
map({ "n" }, "<leader>h", Show_documentation, { desc = "hover" })
-- <leader>K for vim show doc behavior

-- save file
map({ "i", "v", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- quit current file
map("n", "Q", vim.g.safequit and "<cmd>SafeQuit<cr>" or "<cmd>q<cr><esc>", { desc = "quit file" })

wk.add({
    { "cs", group = "+surrounds" },
    { "<leader>t", group = "+tab/Translate" },
    { "<leader>o", group = "+open" },
    { "<leader>p", group = "+preview" },
    { "<leader>r", group = "+refactor" },
})

-- reformat
map({ "n", "v" }, "<leader>rf", function()
    LazyVim.format({ force = true })
end, { desc = "Format" })
-- delete default reformat keymap
vim.keymap.del({ "n", "v" }, "<leader>cf")

-- Custom commands
map("n", "<leader>cr", vim.g.compile_run, { desc = "Compile & Run" })
map("n", "<leader>cu", vim.g.write_nvim_custom_config, { desc = "Update nvim custom config" })
map("n", "<leader>ut", vim.g.toggle_typewriter_mode, { desc = "Typewriter mode" })

vim.cmd([[

command! Edir call feedkeys(":e <C-R>=expand('%:p:h')<CR>/", 'n')

" custom command "cdc" to change directory to the current file's directory
command! CD execute 'cd' expand('%:p:h')

" custom command "cwd" to print the current file's directory
command! Cwd echo expand('%:p:h')

]])

function JumpToNextPlaceholder()
    local search_pattern = "<\\*>"
    local found = vim.fn.search(search_pattern, "W")

    if found ~= 0 then
        vim.cmd('normal! "_diw')
        vim.cmd("startinsert")
    else
        print("No placeholder <*> found")
    end
end

map("n", "]8", JumpToNextPlaceholder, { desc = "Replace next placeholder", noremap = true, silent = true })
