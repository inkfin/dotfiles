-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Unfold all blocks on entry
-- vim.api.nvim_create_autocmd({ "BufReadPost", "FileReadPost" }, {
--     pattern = "*",
--     command = "normal zx zR", -- FIXME: Manually fold and unfold file, strange issue: https://github.com/nvim-treesitter/nvim-treesitter/issues/1226
-- })

-- Set working directory when enter
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        vim.cmd("lcd " .. LazyVim.root())
    end,
})

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
    "nu",
    }, callback = function() vim.g.settab(2) end })
vim.api.nvim_create_autocmd("FileType", { pattern = {
    "markdown",
    "json",
    "cpp",
    "c",
    "python",
    "rust",
    "cmake",
    "norg",
    }, callback = function() vim.g.settab(4) end })
-- stylua: ignore end

-- Copy template files
local template_dirs = {
    vim.fn.expand("$HOME/.config/nvim/template"),
    vim.fn.expand("$HOME/template"),
    vim.fn.expand("$HOME/template/cmake_project"),
}

local function find_template(filepath)
    local filename = vim.fn.fnamemodify(filepath, ":t") -- filename.ext
    local ext = vim.fn.fnamemodify(filepath, ":e") -- ext

    for _, dir in ipairs(template_dirs) do
        -- 1. Try find <filename>.<ext>
        local template_path = dir .. "/" .. filename
        if vim.fn.filereadable(template_path) == 1 then
            return template_path
        end

        -- 2. Try find template.<ext>
        template_path = dir .. "/template." .. ext
        if vim.fn.filereadable(template_path) == 1 then
            return template_path
        end
    end

    return nil
end

vim.api.nvim_create_autocmd("BufNewFile", {
    callback = function(event)
        local template = find_template(event.match)
        if template then
            vim.cmd("silent! 0r " .. template)
        end
    end,
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

-- Set foldlevel and conceallevel for norg files
vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "norg" },
    callback = function()
        vim.wo.foldlevel = 99
        vim.wo.conceallevel = 2
    end,
})

-- Change LspInlayHint color
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#87744d", bg = "NONE" })
    end,
})
