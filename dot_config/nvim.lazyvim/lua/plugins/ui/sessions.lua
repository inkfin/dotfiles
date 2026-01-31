return {
    {
        -- separate buffers for each tab
        "tiagovla/scope.nvim",
        lazy = false,
        version = false,
        config = function()
            require("scope").setup({})
            require("telescope").load_extension("scope")

            vim.keymap.del("n", "<leader>sb")
            vim.keymap.set("n", "<leader>sb", "<CMD>Telescope scope buffers<CR>", { desc = "Buffer", silent = true })
        end,
    },
    {
        -- session persistence
        "folke/persistence.nvim",
        dependencies = {
            { "tiagovla/scope.nvim" },
        },
        opts = function()
            local group = vim.api.nvim_create_augroup("scope-persistence", { clear = true })
            vim.api.nvim_create_autocmd("User", {
                group = group,
                pattern = "PersistenceSavePre",
                callback = function()
                    vim.cmd([[ScopeSaveState]]) -- Scope.nvim saving
                end,
            })
            vim.api.nvim_create_autocmd("User", {
                group = group,
                pattern = "PersistenceLoadPost",
                callback = function()
                    vim.cmd([[ScopeLoadState]]) -- Scope.nvim loading
                end,
            })
        end,
    },
}
