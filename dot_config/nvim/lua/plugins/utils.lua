return {
    -- { "folke/neoconf.nvim", cmd = "Neoconf" },
    -- "folke/neodev.nvim",
    {
        "folke/todo-comments.nvim",
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
        "hedyhli/outline.nvim",
        keys = { { "<leader>cs", false }, { "<leader>oo", "<cmd>Outline<cr>", desc = "Toggle Outline" } },
    },
    {
        "keaising/im-select.nvim",
        enabled = vim.fn.executable("im-select") == 1,
        config = function()
            -- download im-select executable if don't exists
            -- Windows:
            --   curl -L https://github.com/daipeihust/im-select/raw/master/win/out/x86/im-select.exe -o $HOME\.local\bin\im-select.exe
            -- MacOS (brew):
            --   brew tap daipeihust/tap
            --   brew install im-select
            -- Linux:
            --   curl -Ls https://raw.githubusercontent.com/daipeihust/im-select/master/install_mac.sh | sh
            require("im_select").setup({
                -- Async run `default_command` to switch IM or not
                async_switch_im = false,
            })
        end,
    },
    {
        "wakatime/vim-wakatime",
    },
}
