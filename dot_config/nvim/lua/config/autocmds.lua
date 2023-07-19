-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Don't auto commenting new lines
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "",
    command = "set fo-=c fo-=r fo-=o",
})

-- Run chezmoi apply whenever a dotfile is saved
-- autocmd BufWritePost ~/.local/share/chezmoi/* ! chezmoi apply --source-path "%"
vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    pattern = vim.fn.expand("~") .. "/.local/share/chezmoi/*",
    callback = function()
        vim.cmd('!chezmoi apply --source-path "%"')
    end,
})
