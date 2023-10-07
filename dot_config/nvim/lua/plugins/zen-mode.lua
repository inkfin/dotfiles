return {
    {
        "folke/zen-mode.nvim",
        keys = {
            { "<leader>uz", mode = { "n" }, "<Cmd>ZenMode<CR>", desc = "ZenMode" },
            { "<leader>uZ", mode = { "n" }, ":let g:zen_width = 0.", desc = "Set ZenMode width" },
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
        opts = {
            context = 15, -- amount of lines we will try to show around the current line
            exclude = { "*.log" },
        },
    },
}
