-- https://github.com/stevearc/overseer.nvim/blob/master/doc/guides.md#custom-tasks
return {
    name = "clang build single file",
    builder = function()
        -- Full path to current file (see :help expand())
        local file = vim.fn.expand("%:p")
        local file_no_ext = vim.fn.expand("%:t:r")
        return {
            cmd = { "clang++" },
            args = { file, "-o", file_no_ext },
            components = { { "on_output_quickfix", open = true }, "default" },
        }
    end,
    condition = {
        filetype = { "cpp" },
    },
}
