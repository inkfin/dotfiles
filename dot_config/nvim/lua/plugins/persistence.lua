return {
    {
        "folke/persistence.nvim",
        dependencies = {
            {
                "tiagovla/scope.nvim",
                lazy = false,
                config = true,
            },
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
