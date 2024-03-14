return {
    {
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
                file_ignore_patterns = {
                    "node_modules",
                },
            },
        },
    },
    {

        "nvim-telescope/telescope-fzf-native.nvim",
        build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release; cmake --build build --config Release; cmake --install build --prefix build",
        enabled = vim.fn.executable("cmake") == 1,
    },
}
