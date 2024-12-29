-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Unfold all blocks on entry
-- vim.api.nvim_create_autocmd({ "BufReadPost", "FileReadPost" }, {
--     pattern = "*",
--     command = "normal zx zR", -- FIXME: Manually fold and unfold file, strange issue: https://github.com/nvim-treesitter/nvim-treesitter/issues/1226
-- })

-- Don't auto commenting new lines
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "",
    command = "set fo-=c fo-=r fo-=o",
})

-- Set tab for different filetype
-- stylua: ignore start
vim.api.nvim_create_autocmd("FileType", { pattern = {
    "quarto",
    "javascript",
    "typescript",
    "html",
    "css",
    }, callback = function() vim.g.settab(2) end })
vim.api.nvim_create_autocmd("FileType", { pattern = {
    "markdown",
    "json",
    "cpp",
    "c",
    "python",
    "rust",
    "cmake",
    }, callback = function() vim.g.settab(4) end })
-- stylua: ignore end

-- Copy template files
vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = "*.cpp",
    command = "0r $HOME/.config/nvim/template/template.cpp",
})
vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = "CMakeLists.txt",
    command = "0r $HOME/.config/nvim/template/CMakeLists.txt",
})
vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = ".marksman.toml",
    command = "0r $HOME/.config/nvim/template/.marksman.toml",
})
vim.api.nvim_create_autocmd("BufNewFile", {
    pattern = ".clangd",
    command = "0r $HOME/.config/nvim/template/.clangd",
})

-- Run chezmoi apply whenever a dotfile is saved
if not vim.wo.diff then
    vim.cmd([[
        autocmd BufWritePost ~/.local/share/chezmoi/* ! chezmoi apply --source-path %
    ]])
end
---- following not working, not sure why
-- vim.api.nvim_create_autocmd({ "BufWritePost" }, {
--     pattern = { vim.fn.expand("~/.local/share/chezmoi/") .. "*" },
--     callback = function()
--         vim.cmd([[
--             !chezmoi apply --source-path %
--         ]])
--     end,
-- })

-- Disable conceallevel in markdown files
vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "markdown" },
    callback = function()
        vim.wo.conceallevel = 0
    end,
})

-- Change LspInlayHint color
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#87744d", bg = "NONE" })
    end,
})
