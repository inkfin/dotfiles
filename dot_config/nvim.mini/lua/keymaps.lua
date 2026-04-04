-- ~/.config/nvim.mini/lua/keymaps.lua
-- Core keymaps (ported/adapted from nvim.lazyvim/lua/config/keymaps.lua)
-- Loaded last so all plugins are available.

local function map(mode, lhs, rhs, opts)
    opts = vim.tbl_extend("force", { silent = true }, opts or {})
    vim.keymap.set(mode, lhs, rhs, opts)
end

--------------------------
-- Neovide
--------------------------
if vim.g.neovide then
    map("n",           "<D-s>",  "<CMD>w<CR>",     { noremap = true, desc = "Save" })
    map("v",           "<D-c>",  '"+y',            { noremap = true, desc = "Copy" })
    map({ "n", "v" },  "<D-v>",  '"+P',            { noremap = true, desc = "Paste" })
    map({ "c", "t" },  "<D-v>",  "<C-R>+",         { noremap = true, desc = "Paste (cmd/terminal)" })
    map("i",           "<D-v>",  '<ESC>"+pa',      { noremap = true, desc = "Paste (insert)" })
end

--------------------------
-- Handy edits
--------------------------
map("n", "dK", ":normal! v0k$d<CR>",  { noremap = true, desc = "Delete to start of prev line" })
map("n", "dJ", ":normal! d$J<CR>",    { noremap = true, desc = "Delete to end of next line"   })
map("n", "<leader>J", ":normal! J<CR>", { noremap = true, desc = "Join lines" })

-- Paste without overwriting the yank register
map("v", "p", '"_dP', { desc = "Paste (no yank)" })
-- Delete to blackhole (don't pollute yank)
map("n", "x", '"_x',  { desc = "Delete (blackhole)" })
-- Yank to system clipboard
map("v", "Y", '"+y',  { noremap = true, desc = "Yank to clipboard" })

--------------------------
-- Motions
--------------------------
map({ "v", "o" }, "H", "^",       { desc = "H → line start (^)" })
map({ "v", "o" }, "L", "$<left>", { desc = "L → line end ($)"   })

--------------------------
-- Buffer navigation
-- (cycle/move keymaps live in plugins/bufferline.lua)
--------------------------

--------------------------
-- Tab management
--------------------------
map("n", "<leader>ti",      "<cmd>tabe<cr>",  { desc = "New empty tab"   })
map("n", "<leader>td",      "<cmd>tabc<cr>",  { desc = "Delete tab"      })
map("n", "]t",              "<cmd>tabn<cr>",  { desc = "Next tab"        })
map("n", "[t",              "<cmd>tabp<cr>",  { desc = "Prev tab"        })
map("n", "<leader>t<left>", "<cmd>tabm -<cr>",{ desc = "Move tab left"   })
map("n", "<leader>tmh",     "<cmd>-tabm<cr>", { desc = "Move tab left"   })
map("n", "<leader>t<right>","<cmd>tabm +<cr>",{ desc = "Move tab right"  })
map("n", "<leader>tml",     "<cmd>tabm +<cr>",{ desc = "Move tab right"  })

--------------------------
-- Search & view
--------------------------
map("n", "<Esc><Esc>",
    "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
    { desc = "Clear hlsearch / diff update / redraw" })

--------------------------
-- File operations
--------------------------
map({ "i", "v", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
map("n", "Q", "<cmd>q<cr><esc>",                          { desc = "Quit file" })

--------------------------
-- Formatting
--------------------------
map({ "n", "v" }, "<leader>rf", function()
    vim.lsp.buf.format({ async = true })
end, { desc = "Format buffer" })

--------------------------
-- Hover documentation
--------------------------
local function show_documentation()
    for _, ft in ipairs({ "vim", "help" }) do
        if ft == vim.bo.filetype then
            vim.cmd("h " .. vim.fn.expand("<cword>"))
            return
        end
    end
    vim.lsp.buf.hover()
end

map("n", "K",         show_documentation, { desc = "Hover docs" })
map("n", "<leader>h", show_documentation, { desc = "Hover docs" })

--------------------------
-- Placeholder navigation
--------------------------
local function jump_to_next_placeholder()
    local found = vim.fn.search("<\\*>", "W")
    if found ~= 0 then
        vim.cmd('normal! "_diw')
        vim.cmd("startinsert")
    else
        print("No placeholder <*> found")
    end
end

map("n", "]p", jump_to_next_placeholder,
    { noremap = true, desc = "Jump to next <*> placeholder" })

--------------------------
-- Custom Ex commands
--------------------------
vim.cmd([[
    command! Edir  call feedkeys(":e <C-R>=expand('%:p:h')<CR>/", 'n')
    command! CD    execute 'cd' expand('%:p:h')
    command! Cwd   echo expand('%:p:h')
]])
