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

-- handy keymaps
map("n", "<C-a>", "ggVG")

-- Paste over currently selected text without yanking it
map("v", "p", '"_dP', { silent = true })

-- better movements
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({ "n", "v", "o" }, "J", "5j", { silent = true })
map({ "n", "v", "o" }, "K", "5k", { silent = true })
map({ "n", "x" }, "W", "5w", { silent = true })
map({ "n", "x" }, "E", "5e", { silent = true })
map({ "n", "x" }, "B", "5b", { silent = true })
map({ "v", "o" }, "H", "^", { desc = "Use 'H' as '^'" })
map({ "v", "o" }, "L", "$", { desc = "Use 'L' as '$'" })

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
wk.register({
    ["<leader>tm"] = { name = "+tab +move" },
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

-- change 'Hover' action to <leader>h, cancel mapping in ../plugins/LSP.lua
function Show_documentation()
    for _, v in pairs({ "vim", "help" }) do
        if v == vim.bo.filetype then
            vim.cmd("h " .. vim.fn.expand("<cword>"))
            return
        end
    end
    vim.lsp.buf.hover()
end

map({ "n" }, "<leader>h", Show_documentation, { desc = "hover" })

-- save file
map({ "i", "v", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- quit current file
map("n", "Q", "<cmd>q<cr><esc>", { desc = "quit file" })

wk.register({
    ["cs"] = { name = "+surrounds" },
    ["<leader>t"] = { name = "+tab/Translate" },
    ["<leader>o"] = { name = "+open" },
})

-- Custom commands
map("n", "<leader>cr", vim.g.compile_run, { desc = "Compile & Run" })
map("n", "<leader>cu", vim.g.write_nvim_custom_config, { desc = "Update nvim custom config" })
map("n", "<leader>ut", vim.g.toggle_typewriter_mode, { desc = "Typewriter mode" })
