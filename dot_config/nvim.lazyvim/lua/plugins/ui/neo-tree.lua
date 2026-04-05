-- Neo-tree removed in favor of LazyVim's default snacks.nvim explorer.
-- snacks.nvim is already bundled with LazyVim and provides equivalent file
-- browsing via <leader>e / <leader>fe without the extra dependency.

return {
    {
        "stevearc/oil.nvim",
        ---@module 'oil'
        ---@type oil.SetupOpts
        opts = {},
        -- Optional dependencies
        dependencies = { { "nvim-mini/mini.icons", opts = {} } },
        -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
        -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
        lazy = false,
    },
}
