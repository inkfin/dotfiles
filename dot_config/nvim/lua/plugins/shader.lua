local M = {}
local enable_glsl = true
local enable_wgsl = true

-- configure filetypes
-- stylua: ignore start
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, { pattern = {"*.glsl"}, callback = function() vim.bo.filetype = "glsl" end })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, { pattern = {"*.vert"}, callback = function() vim.bo.filetype = "vert" end })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, { pattern = {"*.tesc"}, callback = function() vim.bo.filetype = "tesc" end })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, { pattern = {"*.tese"}, callback = function() vim.bo.filetype = "tese" end })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, { pattern = {"*.frag"}, callback = function() vim.bo.filetype = "frag" end })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, { pattern = {"*.geom"}, callback = function() vim.bo.filetype = "geom" end })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, { pattern = {"*.comp"}, callback = function() vim.bo.filetype = "comp" end })
--stylua: ignore end

local glsl_filetypes = {
    "glsl",
    "vert",
    "tesc",
    "tese",
    "frag",
    "geom",
    "comp",
}

local glsl_config = {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {

        -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#glsl_analyzer
        ---@type lspconfig.options
        servers = {
            glsl_analyzer = {
                cmd = { "glsl_analyzer" },
                filetypes = glsl_filetypes,
                single_file_support = true,
            },
        },
    },
}

vim.treesitter.language.register("glsl", glsl_filetypes)

-- configure filetypes
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = {
        "*.wgsl",
    },
    callback = function()
        vim.bo.filetype = "wgsl"
    end,
})

local wgsl_config = {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
        -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#wgsl_analyzer
        ---@type lspconfig.options
        servers = {
            wgsl_analyzer = {
                cmd = { "wgsl_analyzer" },
                filetypes = {
                    "wgsl",
                },
            },
        },
    },
}

if enable_glsl then
    if vim.fn.executable("glsl_analyzer") == 0 then
        print(
            "Can't find glsl_analyzer in $PATH\nPlease get glsl_analyzer from https://github.com/nolanderc/glsl_analyzer/releases/latest ..."
        )
    else
        table.insert(M, glsl_config)
    end
end

if enable_wgsl then
    table.insert(M, wgsl_config)
end

return M
