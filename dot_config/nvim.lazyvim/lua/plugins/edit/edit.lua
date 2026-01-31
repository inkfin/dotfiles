return {
    {
        "junegunn/vim-easy-align",
        init = function()
            vim.g.easy_align_bypass_fold = 1
        end,
        keys = {
            { "ga", "<Plug>(EasyAlign)", mode = { "x", "v" }, desc = "Align" },
        },
    },
    {
        "folke/todo-comments.nvim",
        opts = {
            highlight = {
                pattern = {
                    -- TODO: match the keyword
                    -- TODO(author): this also matches
                    [[.*<((KEYWORDS)(\(\w*\))?)\s*:]],
                },
            },
            search = {
                pattern = [[\b(KEYWORDS)(?:\(\w+\))?\s*:]],
            },
        },
        -- stylua: ignore
        keys = {
            { "]t", false },
            { "[t", false },
            { "]T", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
            { "[T", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
            { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todo (Trouble)" },
            { "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
            { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
            { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
        },
    },
    {
        "mbbill/undotree",
        keys = {
            -- stylua: ignore
            { "U", function() vim.cmd.UndotreeToggle() vim.cmd.UndotreeFocus() end, mode = "n", desc = "UndotreeToggle" },
        },
        -- https://github.com/mbbill/undotree/blob/master/plugin/undotree.vim#L27
        init = function()
            vim.g.undotree_WindowLayout = 3

            vim.g.undotree_DiffAutoOpen = 0
            if vim.fn.executable("diff") == 1 then
                -- https://github.com/mbbill/undotree/issues/168
                vim.g.undotree_DiffAutoOpen = 1
            end
        end,
    },
    {
        "MagicDuck/grug-far.nvim",
        keys = {
            {
                "<leader>sr",
                function()
                    require("grug-far").open({
                        prefills = { search = vim.fn.expand("<cword>") },
                        visualSelectionUsage = "operate-within-range",
                    })
                end,
                mode = { "n" },
                desc = "Search and Replace Current Buffer",
            },
            {
                "<leader>sr",
                function()
                    require("grug-far").open({
                        visualSelectionUsage = "operate-within-range",
                    })
                end,
                mode = { "x", "v" },
                desc = "Search and Replace in Range",
            },
            {
                "<leader>sR",
                function()
                    require("grug-far").open()
                end,
                mode = { "n", "x" },
                desc = "Search and Replace Global",
            },
        },
    },
}
