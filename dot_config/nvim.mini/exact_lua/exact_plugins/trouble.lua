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

local function jump_trouble_or_fallback(mode, trouble_jump, fallback)
    return function()
        if trouble.is_open({ mode = mode }) then
            trouble[trouble_jump]({ mode = mode, skip_groups = true, jump = true })
        else
            local ok_jump, err = pcall(fallback)
            if not ok_jump then
                vim.notify(err, vim.log.levels.ERROR)
            end
        end
    end
end

map("<leader>xx", "<cmd>Trouble diagnostics toggle focus=true<cr>", "Diagnostics (Trouble)")
map("<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Buffer Diagnostics (Trouble)")
map("<leader>oo", "<cmd>Trouble symbols toggle<cr>", "Symbols (Trouble)")
map("<leader>cS", "<cmd>Trouble lsp focus<cr>", "LSP references/definitions/... (Trouble)")

map("[q", jump_trouble_or_fallback("qflist", "prev", vim.cmd.cprev), "Previous Trouble/Quickfix Item")
map("]q", jump_trouble_or_fallback("qflist", "next", vim.cmd.cnext), "Next Trouble/Quickfix Item")
map("[l", jump_trouble_or_fallback("loclist", "prev", vim.cmd.lprev), "Previous Trouble/Location Item")
map("]l", jump_trouble_or_fallback("loclist", "next", vim.cmd.lnext), "Next Trouble/Location Item")
