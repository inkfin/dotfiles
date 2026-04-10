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
-- Window resizing
--------------------------
map("n", "<C-Up>",    "<cmd>resize +2<cr>",          { desc = "Increase window height" })
map("n", "<C-Down>",  "<cmd>resize -2<cr>",          { desc = "Decrease window height" })
map("n", "<C-Left>",  "<cmd>vertical resize -2<cr>", { desc = "Decrease window width"  })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width"  })

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
map("n", "<Esc>",
    "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
    { desc = "Clear hlsearch / diff update / redraw" })
map("n", "<leader><CR>",
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

map("n", "<leader>uf", function()
    local enabled = not vim.b.autoformat
    vim.b.autoformat = enabled
    vim.notify((enabled and "Enabled" or "Disabled") .. " autoformat for buffer")
end, { desc = "Toggle autoformat (buffer)" })

map("n", "<leader>uF", function()
    vim.g.autoformat = not vim.g.autoformat
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
            vim.b[buf].autoformat = vim.g.autoformat
        end
    end
    vim.notify((vim.g.autoformat and "Enabled" or "Disabled") .. " autoformat globally")
end, { desc = "Toggle autoformat (global)" })

--------------------------
-- Diagnostics
--------------------------
map("n", "<leader>xl", function()
    local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
    if not success and err then
        vim.notify(err, vim.log.levels.ERROR)
    end
end, { desc = "Location List" })

map("n", "<leader>xq", function()
    local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
    if not success and err then
        vim.notify(err, vim.log.levels.ERROR)
    end
end, { desc = "Quickfix List" })

map("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })

map("n", "<leader>ud", function()
    local enabled = not vim.diagnostic.is_enabled()
    vim.diagnostic.enable(enabled)
    vim.notify((enabled and "Enabled" or "Disabled") .. " diagnostics")
end, { desc = "Toggle diagnostics" })

map("n", "<leader>uD", function()
    local bufnr = vim.api.nvim_get_current_buf()
    local enabled = vim.b[bufnr].lsp_disabled == true

    if enabled and (vim.bo[bufnr].filetype == "bigfile" or vim.wo.diff) then
        vim.notify("LSP stays disabled in diff and bigfile buffers", vim.log.levels.WARN)
        return
    end

    vim.b[bufnr].lsp_disabled = not enabled

    if not enabled then
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
            pcall(vim.lsp.buf_detach_client, bufnr, client.id)
            if vim.tbl_isempty(client.attached_buffers or {}) then
                client:stop()
            end
        end
        vim.diagnostic.enable(false, { bufnr = bufnr })
        vim.notify("Disabled LSP for buffer")
        return
    end

    vim.diagnostic.enable(true, { bufnr = bufnr })
    vim.api.nvim_exec_autocmds("FileType", { buffer = bufnr, modeline = false })
    vim.notify("Enabled LSP for buffer")
end, { desc = "Toggle LSP (buffer)" })

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
    command! CD    execute 'cd' fnameescape(expand('%:p:h'))
    command! Cwd   echo expand('%:p:h')
]])
