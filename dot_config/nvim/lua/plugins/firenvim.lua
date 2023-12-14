return {
    "glacambre/firenvim",

    -- Lazy load firenvim
    -- Explanation: https://github.com/folke/lazy.nvim/discussions/463#discussioncomment-4819297
    lazy = not vim.g.started_by_firenvim,
    build = function()
        vim.fn["firenvim#install"](0)
    end,
    opts = function()
        print("hsdoafjsdal;fk")
        vim.g.firenvim_config = {
            globalSettings = { alt = "all" },
            localSettings = {
                [".*"] = {
                    cmdline = "neovim",
                    content = "text",
                    priority = 0,
                    selector = 'textarea:not([readonly], [aria-readonly]), div[role="textbox"]',
                    takeover = "always",
                },
            },
        }
        if vim.go.lines <= 5 then
            vim.go.lines = 5
        end
        if vim.go.columns <= 20 then
            vim.go.columns = 20
        end
    end,
}
