return {
    "nvim-telescope/telescope.nvim",
    opts = {
        defaults = {
            layout_strategy = "flex", -- default horizontal
            layout_config = {
                horizontal = {
                    preview_cutoff = 80,
                },
                vertical = {
                    preview_cutoff = 80,
                },
            },
        },
    },
}
