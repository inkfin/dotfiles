return {
    {
        "nvim-mini/mini.comment",
        opts = {
            options = {
                ignore_blank_line = true,
            },
            mappings = {
                -- Toggle comment (like `gcip` - comment inner paragraph) for both
                -- Normal and Visual modes
                comment = "gc",
                comment_line = "gcc",
                comment_visual = "gc",
                -- Define 'comment' textobject (like `dgc` - delete whole comment block)
                textobject = "gc",
            },
        },
    },
    {
        "JoosepAlviste/nvim-ts-context-commentstring",
        opts = {
            -- change the comment string here
            config = {
                c = "// %s",
                cpp = "// %s",
                -- shader stuff
                glsl = "// %s",
                vert = "// %s",
                tesc = "// %s",
                tese = "// %s",
                frag = "// %s",
                geom = "// %s",
                comp = "// %s",
                wgsl = "// %s",
                nu = "# %s",
            },
        },
    },
    {
        "nvim-mini/mini.surround",
        opts = {
            mappings = {
                add = "gsa", -- Add surrounding in Normal and Visual modes
                delete = "gsd", -- Delete surrounding
                find = "gsf", -- Find surrounding (to the right)
                find_left = "gsF", -- Find surrounding (to the left)
                highlight = "gsh", -- Highlight surrounding
                replace = "gsr", -- Replace surrounding
                update_n_lines = "gsn", -- Update `n_lines`}
            },
        },
    },
}
