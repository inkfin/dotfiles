-- ~/.config/nvim.mini/lua/plugins/telescope.lua
-- nvim-telescope/telescope.nvim: fuzzy finder

local ok, telescope = pcall(require, "telescope")
if not ok then return end

local actions = require("telescope.actions")
local builtin = require("telescope.builtin")

-- Determine the fastest find command available
local function find_command()
    if vim.fn.executable("rg") == 1 then
        return { "rg", "--files", "--color", "never", "-g", "!.git" }
    elseif vim.fn.executable("fd") == 1 then
        return { "fd", "--type", "f", "--color", "never", "-E", ".git" }
    elseif vim.fn.executable("fdfind") == 1 then
        return { "fdfind", "--type", "f", "--color", "never", "-E", ".git" }
    end
end

-- Flash jump inside Telescope results
local function flash_in_telescope(prompt_bufnr)
    local ok_flash, flash = pcall(require, "flash")
    if not ok_flash then return end
    flash.jump({
        pattern = "^",
        label = { after = { 0, 0 } },
        search = {
            mode = "search",
            exclude = {
                function(win)
                    return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
                end,
            },
        },
        action = function(match)
            local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
            picker:set_selection(match.pos[1] - 1)
        end,
    })
end

telescope.setup({
    defaults = {
        prompt_prefix   = " ",
        selection_caret = "  ",
        entry_prefix    = "  ",
        layout_strategy = "flex",
        layout_config = {
            horizontal = { preview_cutoff = 80 },
            vertical   = { preview_cutoff = 80 },
        },
        file_ignore_patterns = {
            "%.git/", "%.svn/", "%.cache/", "node_modules/", "spell/", "elpa/",
        },
        -- Prefer opening in an existing file window
        get_selection_window = function()
            local wins = vim.api.nvim_list_wins()
            table.insert(wins, 1, vim.api.nvim_get_current_win())
            for _, win in ipairs(wins) do
                if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "" then
                    return win
                end
            end
            return 0
        end,
        mappings = {
            i = {
                ["<C-Down>"] = actions.cycle_history_next,
                ["<C-Up>"]   = actions.cycle_history_prev,
                ["<C-f>"]    = actions.preview_scrolling_down,
                ["<C-b>"]    = actions.preview_scrolling_up,
                ["<C-s>"]    = flash_in_telescope,
            },
            n = {
                ["q"] = actions.close,
                ["s"] = flash_in_telescope,
            },
        },
    },
    pickers = {
        find_files = {
            find_command = find_command(),
            hidden = true,
        },
    },
})

-- Load fzf-native extension if available (must be built first: run `make` in its dir)
pcall(telescope.load_extension, "fzf")

-- Load zoxide extension if available
pcall(telescope.load_extension, "zoxide")

--------------------------
-- Keymaps
--------------------------
local map = vim.keymap.set

-- Top-level
map("n", "<leader>,",  "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",  { desc = "Switch Buffer" })
map("n", "<leader>/",  builtin.live_grep,                                               { desc = "Live Grep (cwd)" })
map("n", "<leader>:",  "<cmd>Telescope command_history<cr>",                            { desc = "Command History" })
map("n", "<leader><space>", builtin.find_files,                                         { desc = "Find Files" })

-- Find
map("n", "<leader>ff", builtin.find_files,                                              { desc = "Find Files" })
map("n", "<leader>fF", function() builtin.find_files({ cwd = vim.uv.cwd() }) end,      { desc = "Find Files (cwd)" })
map("n", "<leader>fg", builtin.git_files,                                               { desc = "Find Files (git)" })
map("n", "<leader>fr", builtin.oldfiles,                                                { desc = "Recent Files" })
map("n", "<leader>fb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true ignore_current_buffer=true<cr>", { desc = "Buffers" })

-- Zoxide
map("n", "<leader>fz", function()
    telescope.extensions.zoxide.list()
end, { desc = "Zoxide list" })

-- Git
map("n", "<leader>gc", "<cmd>Telescope git_commits<cr>",  { desc = "Git Commits" })
map("n", "<leader>gl", "<cmd>Telescope git_commits<cr>",  { desc = "Git Log" })
map("n", "<leader>gs", "<cmd>Telescope git_status<cr>",   { desc = "Git Status" })
map("n", "<leader>gS", "<cmd>Telescope git_stash<cr>",    { desc = "Git Stash" })

-- Search
map("n", '<leader>s"', "<cmd>Telescope registers<cr>",                    { desc = "Registers" })
map("n", "<leader>sa", "<cmd>Telescope autocommands<cr>",                  { desc = "Autocommands" })
map("n", "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>",    { desc = "Buffer Lines" })
map("n", "<leader>sc", "<cmd>Telescope command_history<cr>",               { desc = "Command History" })
map("n", "<leader>sC", "<cmd>Telescope commands<cr>",                      { desc = "Commands" })
map("n", "<leader>sd", "<cmd>Telescope diagnostics<cr>",                   { desc = "Diagnostics" })
map("n", "<leader>sD", "<cmd>Telescope diagnostics bufnr=0<cr>",           { desc = "Buffer Diagnostics" })
map("n", "<leader>sg", builtin.live_grep,                                   { desc = "Live Grep" })
map("n", "<leader>sh", "<cmd>Telescope help_tags<cr>",                     { desc = "Help Pages" })
map("n", "<leader>sH", "<cmd>Telescope highlights<cr>",                    { desc = "Highlights" })
map("n", "<leader>sj", "<cmd>Telescope jumplist<cr>",                      { desc = "Jumplist" })
map("n", "<leader>sk", "<cmd>Telescope keymaps<cr>",                       { desc = "Keymaps" })
map("n", "<leader>sm", "<cmd>Telescope marks<cr>",                         { desc = "Marks" })
map("n", "<leader>sM", "<cmd>Telescope man_pages<cr>",                     { desc = "Man Pages" })
map("n", "<leader>so", "<cmd>Telescope vim_options<cr>",                   { desc = "Vim Options" })
map("n", "<leader>sq", "<cmd>Telescope quickfix<cr>",                      { desc = "Quickfix" })
map("n", "<leader>ss", builtin.lsp_document_symbols,                        { desc = "LSP Symbols (buf)" })
map("n", "<leader>sS", builtin.lsp_dynamic_workspace_symbols,               { desc = "LSP Symbols (ws)" })
map("n", "<leader>sw", function() builtin.grep_string({ word_match = "-w" }) end, { desc = "Grep Word" })
map("x", "<leader>sw", builtin.grep_string,                                 { desc = "Grep Selection" })
