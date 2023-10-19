return {
    {
        "folke/zen-mode.nvim",
        keys = {
            { "<leader>uz", mode = { "n" }, "<Cmd>ZenMode<CR>", desc = "ZenMode" },
            { "<leader>uW", mode = { "n" }, ":let g:zen_width = 0.", desc = "Set ZenMode width" },
            { "<leader>uH", mode = { "n" }, ":let g:zen_height = 0.", desc = "Set ZenMode height" },
        },
        opts = {
            window = {
                width = function()
                    local num_zen_width = 255
                    if vim.g.zen_width <= 1 then
                        local winwidth = vim.fn.winwidth(0)
                        num_zen_width = vim.g.zen_width * winwidth
                    elseif vim.g.zen_width > 1 then
                        num_zen_width = vim.g.zen_width
                    else
                        print("Invalid zen_width: " .. vim.g.zen_width .. "!")
                    end
                    return num_zen_width
                end, -- width will be 85% of the editor width
                height = function()
                    local num_zen_height = 1
                    if vim.g.zen_height <= 1 then
                        local winheight = vim.fn.winheight(0)
                        num_zen_height = vim.g.zen_height * winheight
                    elseif vim.g.zen_height > 1 then
                        num_zen_height = vim.g.zen_height
                    else
                        print("Invalid zen_height: " .. vim.g.zen_height .. "!")
                    end
                    return num_zen_height
                end, -- width will be 85% of the editor width
            },
            plugins = {
                options = {
                    enabled = true,
                    ruler = false,
                    laststatus = 0,
                },
                tmux = { enabled = false },
            },
            -- -- toggle typewriter mode
            -- on_open = function()
            --     vim.wo.scrolloff = 999
            -- end,
            -- on_close = function()
            --     vim.wo.scrolloff = 5
            -- end,
        },
    },
    {
        "folke/twilight.nvim",
        keys = {
            { "<leader>uZ", mode = { "n" }, "<Cmd>Twilight<CR>", desc = "toggle Twilight" },
        },
        opts = {
            context = 15, -- amount of lines we will try to show around the current line
            exclude = { "log", "markdown" },
        },
    },
}
