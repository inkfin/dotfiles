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
        "folke/which-key.nvim",
        ---@class wk.Opts
        opts = {
            preset = "classic",
        },
    },
    {
        "folke/snacks.nvim",
        opts = {
            scroll = { enabled = false },
            zen = { enabled = false },
            explorer = { enabled = false },
            image = { enabled = false }, -- use image.nvim
        },
    },
    {
        "mikavilpas/yazi.nvim",
        keys = {
            {
                "<space>yy",
                "<cmd>Yazi<cr>",
                desc = "Open yazi (Directory of Current File)",
                mode = { "n", "v" },
            },
        },
        ---@type YaziConfig
        opts = {
            integrations = {
                grep_in_directory = function(dir)
                    Snacks.picker.grep({ dirs = { dir } })
                end,
                grep_in_selected_files = function(_, dirs)
                    Snacks.picker.grep({ dirs = dirs })
                end,
            },
        },
    },
    {
        "hedyhli/outline.nvim",
        keys = { { "<leader>cs", false }, { "<leader>oo", "<cmd>Outline<cr>", desc = "Toggle Outline" } },
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
        'MagicDuck/grug-far.nvim',
        enabled = false,
        keys = {
            { '<leader>sr', function() require("grug-far").open({
                prefills = { search = vim.fn.expand("<cword>") },
                visualSelectionUsage = "operate-within-range",
            }) end, mode = {'n'}, desc = 'Search and Replace Current Buffer' },
            { '<leader>sr', function() require("grug-far").open({
                visualSelectionUsage = "operate-within-range",
            }) end, mode = {'x', 'v'}, desc = 'Search and Replace in Range' },
            { '<leader>sR', function() require("grug-far").open() end, mode = {'n', 'x'}, desc = 'Search and Replace Global' },
        }
    },
    {
        "keaising/im-select.nvim",
        enabled = _G.disable_plugins.rime == true and not _G.disable_plugins.im_select and (vim.fn.executable(
            "im-select"
        ) == 1 or (vim.fn.has("mac") == 1 and vim.fn.executable("macism"))),
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
        enabled = not _G.disable_plugins.wakatime,
    },
    -- {

    --     "vhyrro/luarocks.nvim",
    --     priority = 1000,
    --     opts = function(_, opts)
    --         if vim.fn.has("mac") then
    --             opts.luarocks_build_args = {
    --                 "--with-lua-include=/usr/include",
    --             }
    --         end
    --     end,
    -- },
}
