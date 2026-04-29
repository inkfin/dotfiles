-- ~/.config/nvim.mini/lua/plugins/telescope.lua
-- fzf-lua picker configuration replacing Telescope

local cfg = require("config")

require("pack").add({
    "https://github.com/ibhagwan/fzf-lua",
})

local ok, fzf = pcall(require, "fzf-lua")
if not ok then return end

local actions = require("fzf-lua.actions")

fzf.setup({
    "telescope",
    fzf_colors = true,
    fzf_opts = {
        ["--no-scrollbar"] = true,
    },
    winopts = {
        width = 0.85,
        height = 0.8,
        row = 0.5,
        col = 0.5,
        preview = {
            scrollchars = { "┃", "" },
        },
    },
    keymap = {
        fzf = {
            ["ctrl-q"] = "select-all+accept",
            ["ctrl-u"] = "half-page-up",
            ["ctrl-d"] = "half-page-down",
            ["ctrl-f"] = "preview-page-down",
            ["ctrl-b"] = "preview-page-up",
        },
        builtin = {
            ["<c-f>"] = "preview-page-down",
            ["<c-b>"] = "preview-page-up",
        },
    },
    files = {
        cwd_prompt = false,
        hidden = true,
        actions = {
            ["alt-i"] = { actions.toggle_ignore },
            ["alt-h"] = { actions.toggle_hidden },
        },
    },
    grep = {
        actions = {
            ["alt-i"] = { actions.toggle_ignore },
            ["alt-h"] = { actions.toggle_hidden },
        },
    },
})

local function call(name, opts)
    return function()
        return fzf[name](opts or {})
    end
end

local function root_call(name, opts)
    return function()
        local merged = vim.tbl_extend("force", { cwd = cfg.project_root(0) }, opts or {})
        return fzf[name](merged)
    end
end

local function pick_search_dir(callback)
    return function()
        fzf.zoxide({
            prompt = "Search Dir> ",
            winopts = { title = " Search Directory " },
            actions = {
                -- zoxide output is a directory path, so we can feed it back into
                -- any picker that accepts `cwd` and let the user choose the
                -- search root interactively.
                ["default"] = function(selected)
                    local dir = selected and selected[1]
                    if not dir or dir == "" then return end
                    callback(vim.trim(dir))
                end,
            },
        })
    end
end

local function choose_files_root()
    return pick_search_dir(function(dir)
        fzf.files({ cwd = dir })
    end)
end

local function choose_grep_root()
    return pick_search_dir(function(dir)
        fzf.live_grep({ cwd = dir })
    end)
end

local function grep_word()
    fzf.grep_cword({ search = vim.fn.expand("<cword>"), cwd = cfg.project_root(0) })
end

local function grep_visual()
    fzf.grep_visual({ cwd = cfg.project_root(0) })
end

local map = vim.keymap.set

-- Top-level
map("n", "<leader>,",  "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>",  { desc = "Switch Buffer" })
map("n", "<leader>/",  root_call("live_grep"),                                      { desc = "Live Grep (root)" })
map("n", "<leader>:",  "<cmd>FzfLua command_history<cr>",                           { desc = "Command History" })
map("n", "<leader><space>", root_call("files"),                                     { desc = "Find Files (root)" })

-- Find
map("n", "<leader>ff", root_call("files"),                                          { desc = "Find Files (root)" })
map("n", "<leader>fF", call("files", { cwd = vim.uv.cwd() }),                       { desc = "Find Files (cwd)" })
map("n", "<leader>fR", choose_files_root(),                                         { desc = "Find Files (choose dir)" })
map("n", "<leader>fg", "<cmd>FzfLua git_files<cr>",                                 { desc = "Find Files (git)" })
map("n", "<leader>fr", "<cmd>FzfLua oldfiles<cr>",                                  { desc = "Recent Files" })
map("n", "<leader>fb", "<cmd>FzfLua buffers sort_mru=true sort_lastused=true<cr>",  { desc = "Buffers" })

-- Zoxide
map("n", "<leader>fz", "<cmd>FzfLua zoxide<cr>",                                    { desc = "Zoxide list" })

-- Git
map("n", "<leader>gf", "<cmd>FzfLua git_bcommits<cr>",                              { desc = "Git Current File History" })
map("n", "<leader>gc", "<cmd>FzfLua git_commits<cr>",                               { desc = "Git Commits" })
map("n", "<leader>gl", "<cmd>FzfLua git_commits<cr>",                               { desc = "Git Log" })
map("n", "<leader>gs", "<cmd>FzfLua git_status<cr>",                                { desc = "Git Status" })
map("n", "<leader>gS", "<cmd>FzfLua git_stash<cr>",                                 { desc = "Git Stash" })

-- Search
map("n", '<leader>s"', "<cmd>FzfLua registers<cr>",                                 { desc = "Registers" })
map("n", "<leader>sa", "<cmd>FzfLua autocmds<cr>",                                  { desc = "Autocommands" })
map("n", "<leader>sb", "<cmd>FzfLua blines<cr>",                                    { desc = "Buffer Lines" })
map("n", "<leader>sc", "<cmd>FzfLua command_history<cr>",                           { desc = "Command History" })
map("n", "<leader>sC", "<cmd>FzfLua commands<cr>",                                  { desc = "Commands" })
map("n", "<leader>sd", "<cmd>FzfLua diagnostics_workspace<cr>",                     { desc = "Diagnostics" })
map("n", "<leader>sD", "<cmd>FzfLua diagnostics_document<cr>",                      { desc = "Buffer Diagnostics" })
map("n", "<leader>sg", root_call("live_grep"),                                      { desc = "Live Grep (root)" })
map("n", "<leader>sG", choose_grep_root(),                                          { desc = "Live Grep (choose dir)" })
map("n", "<leader>sh", "<cmd>FzfLua help_tags<cr>",                                 { desc = "Help Pages" })
map("n", "<leader>sH", "<cmd>FzfLua highlights<cr>",                                { desc = "Highlights" })
map("n", "<leader>sj", "<cmd>FzfLua jumps<cr>",                                     { desc = "Jumplist" })
map("n", "<leader>sk", "<cmd>FzfLua keymaps<cr>",                                   { desc = "Keymaps" })
map("n", "<leader>mm", "<cmd>FzfLua marks<cr>",                                     { desc = "Bookmarks" })
map("n", "<leader>sm", "<cmd>FzfLua marks<cr>",                                     { desc = "Marks" })
map("n", "<leader>sM", "<cmd>FzfLua man_pages<cr>",                                 { desc = "Man Pages" })
map("n", "<leader>so", "<cmd>FzfLua nvim_options<cr>",                              { desc = "Vim Options" })
map("n", "<leader>sq", "<cmd>FzfLua quickfix<cr>",                                  { desc = "Quickfix" })
map("n", "<leader>ss", "<cmd>FzfLua lsp_document_symbols<cr>",                      { desc = "LSP Symbols (buf)" })
map("n", "<leader>sS", "<cmd>FzfLua lsp_live_workspace_symbols<cr>",                { desc = "LSP Symbols (ws)" })
map("n", "<leader>sw", grep_word,                                                   { desc = "Grep Word" })
map("x", "<leader>sw", grep_visual,                                                 { desc = "Grep Selection" })
