-- ~/.config/nvim.mini/lua/plugins/terminal.lua
-- Float terminals via toggleterm.nvim

require("pack").add("https://github.com/akinsho/toggleterm.nvim")

local ok, toggleterm = pcall(require, "toggleterm")
if not ok then return end

toggleterm.setup({
    size = function(term)
        if term.direction == "horizontal" then
            return math.floor(vim.o.lines * 0.35)
        end
        return math.floor(vim.o.columns * 0.5)
    end,
    open_mapping  = nil,    -- we set keymaps manually below
    autochdir     = true,
    shade_terminals = true,
    start_in_insert = true,
    persist_mode    = true,
    direction       = "float",
    close_on_exit   = true,
    shell           = vim.o.shell,
    float_opts = {
        border   = "rounded",
        winblend = 0,
    },
})

local Terminal = require("toggleterm.terminal").Terminal

-- <C-/> — bottom horizontal shell
local shell = Terminal:new({
    direction = "horizontal",
    hidden    = true,
})

vim.keymap.set({ "n", "t" }, "<C-/>", function() shell:toggle() end,
    { silent = true, desc = "Toggle bottom terminal" })
-- Some terminals send <C-_> for <C-/>
vim.keymap.set({ "n", "t" }, "<C-_>", function() shell:toggle() end,
    { silent = true, desc = "Toggle bottom terminal" })

-- <leader>gg — lazygit (centered float)
local function get_root()
    local ok_cfg, cfg = pcall(require, "config")
    if ok_cfg then
        return vim.fs.root(0, cfg.root_patterns)
    end
end

local lazygit = Terminal:new({
    cmd       = "lazygit",
    dir       = "git_dir",
    direction = "float",
    hidden    = true,
    float_opts = {
        border = "rounded",
        width  = function() return math.floor(vim.o.columns * 0.9) end,
        height = function() return math.floor(vim.o.lines   * 0.85) end,
    },
    on_open = function(term)
        -- override dir to project root if detectable
        local root = get_root()
        if root then term.dir = root end
        vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>",
            { buffer = term.bufnr, silent = true })
    end,
})

vim.keymap.set("n", "<leader>gg", function()
    if vim.fn.executable("lazygit") == 0 then
        vim.notify("lazygit not found in PATH", vim.log.levels.ERROR)
        return
    end
    lazygit:toggle()
end, { silent = true, desc = "Lazygit" })
