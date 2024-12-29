if _G.disable_plugins.image then
    return {}
end

-- disable this plugin if in diff mode
if vim.wo.diff then
    return {}
end

local is_term_support_kitty = -- only enable in supported terms
    vim.fn.getenv("TERM_PROGRAM") == "WezTerm" -- Wezterm supports kitty
    or vim.fn.getenv("TERM_PROGRAM") == "Kitty"

local is_term_support_ueberzug = -- ueberzug for other terms
    vim.fn.getenv("TERM_PROGRAM") == "iTerm.app" -- iTerm2

return {
    {
        "3rd/image.nvim",
        enabled = vim.fn.has("win32") == 0 -- sorry, no windows for now
            and not vim.g.neovide
            and (
                is_term_support_kitty -- kitty native support
                or (is_term_support_ueberzug and vim.fn.executable("ueberzug") == 1)
            ),
        build = not (is_term_support_kitty or vim.fn.executable("magick") == 1), -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
        opts = {
            backend = is_term_support_kitty and "kitty" or "ueberzug",
            processor = vim.fn.executable("magick") == 1 and "magick_cli" or "magick_rock",
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
