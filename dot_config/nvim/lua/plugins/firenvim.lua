-- stylua: ignore
-- if true then return {} end

return {
    "glacambre/firenvim",

    -- Lazy load firenvim
    -- Explanation: https://github.com/folke/lazy.nvim/discussions/463#discussioncomment-4819297
    lazy = not vim.g.started_by_firenvim,
    build = ":call firenvim#install(0)",
    opts = function()
        vim.g.firenvim_config = {
            globalSettings = { alt = "all" },
            localSettings = {
                [".*"] = {
                    cmdline = "firenvim", --"neovim",
                    content = "text",
                    priority = 0,
                    selector = 'textarea:not([readonly], [aria-readonly]), div[role="textbox"]',
                    takeover = "never",
                },
                [".leetcode.com"] = {
                    priority = 99,
                    takeover = "always",
                },
                [".google.com"] = {
                    selector = 'textarea:not([class="gLFyf"])',
                },
                [".bing.com"] = {
                    selector = 'textarea:not([class="b_searchbox"])',
                },
                [".sshx.io"] = {
                    takeover = "never",
                    priority = 99,
                },
                [".openai.com"] = {
                    takeover = "never",
                    priority = 99,
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
