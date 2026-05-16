-- ~/.config/nvim.mini/lua/plugins/picker.lua
-- Snacks picker keymaps.

local cfg = require("config")

local function files(opts)
    Snacks.picker.files(vim.tbl_extend("force", { hidden = true }, opts or {}))
end

local function grep(opts)
    Snacks.picker.grep(opts or {})
end

local function root_files(opts)
    return function()
        files(vim.tbl_extend("force", { cwd = cfg.project_root(0) }, opts or {}))
    end
end

local function cwd_files(opts)
    return function()
        files(vim.tbl_extend("force", { cwd = vim.uv.cwd() }, opts or {}))
    end
end

local function root_grep(opts)
    return function()
        grep(vim.tbl_extend("force", { cwd = cfg.project_root(0) }, opts or {}))
    end
end

local function pick_search_dir(callback)
    return function()
        Snacks.picker.pick({
            source = "zoxide",
            title = "Search Directory",
            confirm = function(picker, item)
                picker:close()
                if not item then return end
                vim.schedule(function()
                    callback(vim.fs.normalize(item.file or item.text))
                end)
            end,
        })
    end
end

local function choose_files_root()
    return pick_search_dir(function(dir)
        files({ cwd = dir })
    end)
end

local function choose_grep_root()
    return pick_search_dir(function(dir)
        grep({ cwd = dir })
    end)
end

local function grep_word()
    Snacks.picker.grep_word({ cwd = cfg.project_root(0) })
end

local map = vim.keymap.set

-- Top-level
map("n", "<leader>,", function()
    Snacks.picker.buffers()
end, { desc = "Switch Buffer" })
map("n", "<leader>/", root_grep(),                                               { desc = "Live Grep (root)" })
map("n", "<leader>:", function()
    Snacks.picker.command_history()
end, { desc = "Command History" })
map("n", "<leader><space>", root_files(),                                         { desc = "Find Files (root)" })

-- Find
map("n", "<leader>ff", root_files(),                                              { desc = "Find Files (root)" })
map("n", "<leader>fF", cwd_files(),                                               { desc = "Find Files (cwd)" })
map("n", "<leader>fR", choose_files_root(),                                       { desc = "Find Files (choose dir)" })
map("n", "<leader>fg", function()
    Snacks.picker.git_files()
end, { desc = "Find Files (git)" })
map("n", "<leader>fr", function()
    Snacks.picker.recent()
end, { desc = "Recent Files" })
map("n", "<leader>fb", function()
    Snacks.picker.buffers()
end, { desc = "Buffers" })

-- Zoxide
map("n", "<leader>fz", function()
    Snacks.picker.zoxide()
end, { desc = "Zoxide list" })

-- Git
map("n", "<leader>gf", function()
    Snacks.picker.git_log_file()
end, { desc = "Git Current File History" })
map("n", "<leader>gc", function()
    Snacks.picker.git_log()
end, { desc = "Git Commits" })
map("n", "<leader>gL", function()
    Snacks.picker.git_log()
end, { desc = "Git Log (cwd)" })
map("n", "<leader>gl", function()
    Snacks.picker.git_log({ cwd = cfg.project_root(0) })
end, { desc = "Git Log" })
map("n", "<leader>gb", function()
    Snacks.picker.git_log_line()
end, { desc = "Git Blame Line" })
map("n", "<leader>gd", function()
    Snacks.picker.git_diff()
end, { desc = "Git Diff (hunks)" })
map("n", "<leader>gD", function()
    Snacks.picker.git_diff({ base = "origin", group = true })
end, { desc = "Git Diff (origin)" })
map("n", "<leader>gs", function()
    Snacks.picker.git_status()
end, { desc = "Git Status" })
map("n", "<leader>gS", function()
    Snacks.picker.git_stash()
end, { desc = "Git Stash" })

-- Search
map("n", "<leader>s\"", function()
    Snacks.picker.registers()
end, { desc = "Registers" })
map("n", "<leader>sa", function()
    Snacks.picker.autocmds()
end, { desc = "Autocommands" })
map("n", "<leader>sb", function()
    Snacks.picker.lines()
end, { desc = "Buffer Lines" })
map("n", "<leader>sc", function()
    Snacks.picker.command_history()
end, { desc = "Command History" })
map("n", "<leader>sC", function()
    Snacks.picker.commands()
end, { desc = "Commands" })
map("n", "<leader>sd", function()
    Snacks.picker.diagnostics()
end, { desc = "Diagnostics" })
map("n", "<leader>sD", function()
    Snacks.picker.diagnostics_buffer()
end, { desc = "Buffer Diagnostics" })
map("n", "<leader>sg", root_grep(),                                               { desc = "Live Grep (root)" })
map("n", "<leader>sG", choose_grep_root(),                                        { desc = "Live Grep (choose dir)" })
map("n", "<leader>sh", function()
    Snacks.picker.help()
end, { desc = "Help Pages" })
map("n", "<leader>sH", function()
    Snacks.picker.highlights()
end, { desc = "Highlights" })
map("n", "<leader>sj", function()
    Snacks.picker.jumps()
end, { desc = "Jumplist" })
map("n", "<leader>sk", function()
    Snacks.picker.keymaps()
end, { desc = "Keymaps" })
map("n", "<leader>mm", function()
    Snacks.picker.marks()
end, { desc = "Bookmarks" })
map("n", "<leader>sm", function()
    Snacks.picker.marks()
end, { desc = "Marks" })
map("n", "<leader>sM", function()
    Snacks.picker.man()
end, { desc = "Man Pages" })
map("n", "<leader>so", "<cmd>options<cr>",                                       { desc = "Vim Options" })
map("n", "<leader>sq", function()
    Snacks.picker.qflist()
end, { desc = "Quickfix" })
map("n", "<leader>ss", function()
    Snacks.picker.lsp_symbols()
end, { desc = "LSP Symbols (buf)" })
map("n", "<leader>sS", function()
    Snacks.picker.lsp_workspace_symbols()
end, { desc = "LSP Symbols (ws)" })
map({ "n", "x" }, "<leader>sw", grep_word,                                      { desc = "Grep Word" })
