-- ~/.config/nvim.mini/lua/plugins/flash.lua
-- flash.nvim: fast jump motions (ported from nvim.lazyvim)

local ok, flash = pcall(require, "flash")
if not ok then return end

flash.setup({
    modes = {
        char   = { enabled = false }, -- don't override f/F/t/T
        search = { enabled = false }, -- don't override /
    },
})

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- s  → Flash jump (label-based)
map({ "n", "x", "o" }, "s", function() flash.jump() end,
    vim.tbl_extend("force", opts, { desc = "Flash" }))

-- S  → Flash Treesitter (select nodes)
map({ "n", "o", "x" }, "S", function() flash.treesitter() end,
    vim.tbl_extend("force", opts, { desc = "Flash Treesitter" }))

-- r  → Remote Flash (operator-pending: act on distant text object)
map("o", "r", function() flash.remote() end,
    vim.tbl_extend("force", opts, { desc = "Remote Flash" }))

-- R  → Treesitter Search (operator/visual)
map({ "o", "x" }, "R", function() flash.treesitter_search() end,
    vim.tbl_extend("force", opts, { desc = "Treesitter Search" }))

-- <C-s> in command mode → toggle Flash search mode
map("c", "<C-s>", function() flash.toggle() end,
    vim.tbl_extend("force", opts, { desc = "Toggle Flash Search" }))

-- t  → jump to a diagnostic and open float (replaces t/T char-motion)
map({ "n", "x", "o" }, "t", function()
    flash.jump({
        matcher = function(win)
            return vim.tbl_map(function(diag)
                return {
                    pos     = { diag.lnum + 1, diag.col },
                    end_pos = { diag.end_lnum + 1, diag.end_col - 1 },
                }
            end, vim.diagnostic.get(vim.api.nvim_win_get_buf(win)))
        end,
        action = function(match, state)
            vim.api.nvim_win_call(match.win, function()
                vim.api.nvim_win_set_cursor(match.win, match.pos)
                vim.diagnostic.open_float()
            end)
            state:restore()
        end,
    })
end, vim.tbl_extend("force", opts, { desc = "Flash: show diagnostic" }))
