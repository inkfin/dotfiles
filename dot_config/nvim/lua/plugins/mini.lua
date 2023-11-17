return {
    {
        "echasnovski/mini.comment",
        version = "*",
        opts = {
            options = {
                ignore_blank_line = true,
            },
            mappings = {
                -- Toggle comment (like `gcip` - comment inner paragraph) for both
                -- Normal and Visual modes
                comment = "<leader>cc",
                comment_visual = "<leader>cc",

                -- Toggle comment on current line
                comment_line = "<leader>ci",

                -- Define 'comment' textobject (like `dgc` - delete whole comment block)
                textobject = "<leader>cc",
            },
        },
    },
    {
        "JoosepAlviste/nvim-ts-context-commentstring",
        opts = {
            -- change the comment string here
            config = {
                cpp = "// %s",
            },
        },
    },
    {
        "echasnovski/mini.surround",
        version = "*",
        opts = {
            mappings = {
                add = "csa", -- Add surrounding in Normal and Visual modes
                delete = "csd", -- Delete surrounding
                find = "csf", -- Find surrounding (to the right)
                find_left = "csF", -- Find surrounding (to the left)
                highlight = "csh", -- Highlight surrounding
                replace = "csr", -- Replace surrounding
                update_n_lines = "csn", -- Update `n_lines`}
            },
        },
    },
}
