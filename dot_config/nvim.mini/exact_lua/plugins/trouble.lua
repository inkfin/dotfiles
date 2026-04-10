-- ~/.config/nvim.mini/lua/plugins/trouble.lua
-- Trouble: diagnostics and list UI, matching the LazyVim-style mappings.

require("pack").add({
    "https://github.com/MunifTanjim/nui.nvim",
    "https://github.com/folke/trouble.nvim",
})

local ok, trouble = pcall(require, "trouble")
if not ok then return end

trouble.setup({
    modes = {
        lsp = {
            win = { position = "right" },
        },
    },
})

local function map(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
end

map("<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", "Diagnostics (Trouble)")
map("<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Buffer Diagnostics (Trouble)")
map("<leader>cs", "<cmd>Trouble symbols toggle<cr>", "Symbols (Trouble)")
map("<leader>cS", "<cmd>Trouble lsp toggle<cr>", "LSP references/definitions/... (Trouble)")
map("<leader>xL", "<cmd>Trouble loclist toggle<cr>", "Location List (Trouble)")
map("<leader>xQ", "<cmd>Trouble qflist toggle<cr>", "Quickfix List (Trouble)")

map("[q", function()
    if trouble.is_open() then
        trouble.prev({ skip_groups = true, jump = true })
    else
        local ok_prev, err = pcall(vim.cmd.cprev)
        if not ok_prev then
            vim.notify(err, vim.log.levels.ERROR)
        end
    end
end, "Previous Trouble/Quickfix Item")

map("]q", function()
    if trouble.is_open() then
        trouble.next({ skip_groups = true, jump = true })
    else
        local ok_next, err = pcall(vim.cmd.cnext)
        if not ok_next then
            vim.notify(err, vim.log.levels.ERROR)
        end
    end
end, "Next Trouble/Quickfix Item")
