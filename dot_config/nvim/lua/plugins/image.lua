if _G.disable_plugins.image then
    return {}
end

return {
    {
        "3rd/image.nvim",
        enabled = vim.fn.executable("ueberzug") == 1,
        -- build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
        opts = {
            backend = "ueberzug",
            processor = "magick_cli", -- or "magick_rock"
            max_width = 100,
            max_height = 12,
            max_height_window_percentage = math.huge, -- requirement from molten-nvim
            max_width_window_percentage = math.huge,
            window_overlap_clear_enabled = true,
            window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" }, -- copied from molten-nvim
            integrations = {
                markdown = {
                    enabled = true,
                    clear_in_insert_mode = false,
                    download_remote_images = true,
                    only_render_image_at_cursor = false,
                    floating_windows = false, -- if true, images will be rendered in floating markdown windows
                    filetypes = { "markdown", "quarto", "vimwiki" },
                },
            },
        },
    },
}
