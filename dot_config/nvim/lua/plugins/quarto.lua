--- Quarto nivm configuration
--- https://github.com/jmbuhr/quarto-nvim-kickstarter/blob/main/lua/plugins/quarto.lua
--- https://github.com/jmbuhr/lazyvim-starter-for-quarto/blob/main/lua/plugins/quarto.lua

return {

    -- this taps into vim.ui.select and vim.ui.input
    -- and in doing so currently breaks renaming in otter.nvim
    { "stevearc/dressing.nvim", enabled = vim.bo.filetype ~= "quarto" },

    {
        "quarto-dev/quarto-nvim",
        ft = "quarto",
        dependencies = {
            "jmbuhr/otter.nvim",
            opts = {
                buffers = {
                    set_filetype = true,
                },
            },
        },
        opts = {
            lspFeatures = {
                languages = { "python", "bash", "html", "lua" },
            },
            codeRunner = {
                enabled = true,
                default_method = "slime",
            },
            keymap = {
                hover = "<leader>h",
                definition = "gd",
                type_definition = "gD",
                rename = "<leader>rn",
                format = "<leader>fm",
                references = "gr",
            },
        },
        -- stylua: ignore
        keys = {
            { "<localleader>qa", "<cmd>QuartoActivate<cr>", desc = "quarto activate" },
            { "<localleader>qp", "<cmd>QuartoPreview<cr>", desc = "quarto preview" },
            { "<localleader>qq", "<cmd>QuartoClosePreview<cr>", desc = "quarto close" },
            { "<localleader>qh", ":QuartoHelp ", desc = "quarto help" },
            { "<localleader>qe", function() require("otter").export() end, desc = "quarto export" },
            { "<localleader>qE", function() require("otter").export(true) end, desc = "quarto export overwrite" },
            { "<localleader>rc", function() require("quarto.runner").run_cell() end, desc = "run cell" },
            { "<localleader>rc", function() require("quarto.runner").run_above() end, desc = "run cell and above" },
            { "<localleader>rA", function() require("quarto.runner").run_all() end, desc = "run all cells" },
            { "<localleader>rl", function() require("quarto.runner").run_line() end, desc = "run line" },
            { "<localleader>r", mode = { "v" }, function() require("quarto.runner").run_range() end, desc = "run visual range" },
            -- { "<localleader>rr", ":QuartoSendAbove<cr>", desc = "quarto run to cursor" },
            { "<localleader>ra", ":QuartoSendAll<cr>", desc = "quarto run all" },
            { "<localleader><cr>", ":SlimeSend<cr>", desc = "send code chunk" },
            { "<c-cr>", "<esc>:SlimeSend<cr>i", mode = "i", desc = "send code chunk" },
            { "<cr>", "<Plug>SlimeRegionSend<cr>", mode = "v", desc = "send code chunk" },
            -- { "<localleader>tr", ":split term://R<cr>", desc = "terminal: R" },
            { "<localleader>ti", ":split term://ipython<cr>", desc = "terminal: ipython" },
            { "<localleader>tp", ":split term://python<cr>", desc = "terminal: python" },
            -- { "<localleader>tj", ":split term://julia<cr>", desc = "terminal: julia" },
            { "K", false },
        },
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = { "jmbuhr/otter.nvim" },
        opts = function(_, opts)
            ---@param opts cmp.ConfigSchema
            local cmp = require("cmp")
            opts.sources = cmp.config.sources(vim.list_extend(opts.sources, { { name = "otter" } }))
        end,
    },

    -- send code from python/r/qmd documets to a terminal or REPL
    -- like ipython, R, bash
    {
        "jpalardy/vim-slime",
        ft = "quarto",
        config = function()
            vim.b["quarto_is_" .. "python" .. "_chunk"] = false
            Quarto_is_in_python_chunk = function()
                require("otter.tools.functions").is_otter_language_context("python")
            end

            vim.cmd([[

            let g:slime_dispatch_ipython_pause = 100
            function SlimeOverride_EscapeText_quarto(text)
            call v:lua.Quarto_is_in_python_chunk()
            if exists('g:slime_python_ipython') && len(split(a:text,"\n")) > 1 && b:quarto_is_python_chunk
            return ["%cpaste -q\n", g:slime_dispatch_ipython_pause, a:text, "--", "\n"]
            else
            return a:text
            end
            endfunction

            ]])

            local function mark_terminal()
                vim.g.slime_last_channel = vim.b.terminal_job_id
                vim.print(vim.g.slime_last_channel)
            end

            local function set_terminal()
                vim.b.slime_config = { jobid = vim.g.slime_last_channel }
            end

            vim.b.slime_cell_delimiter = "# %%"

            -- if vim.fn.exists("$TMUX") == 1 then
            --     -- slime, tmux
            --     vim.g.slime_target = "tmux"
            --     vim.g.slime_bracketed_paste = 1
            --     vim.g.slime_default_config = { socket_name = "default", target_pane = ".2" }
            -- else
            -- slime, neovvim terminal
            vim.g.slime_target = "neovim"
            vim.g.slime_python_ipython = 1
            -- vim.g.slime_bracketed_paste = 1
            -- end

            local function toggle_slime_tmux_nvim()
                if vim.g.slime_target == "tmux" then
                    pcall(function()
                        vim.b.slime_config = nil
                        vim.g.slime_default_config = nil
                    end)
                    -- slime, neovvim terminal
                    vim.g.slime_target = "neovim"
                    vim.g.slime_bracketed_paste = 0
                    vim.g.slime_python_ipython = 1
                    print("In neovim terminal mode")
                elseif vim.g.slime_target == "neovim" then
                    pcall(function()
                        vim.b.slime_config = nil
                        vim.g.slime_default_config = nil
                    end)
                    -- -- slime, tmux
                    vim.g.slime_target = "tmux"
                    vim.g.slime_bracketed_paste = 1
                    vim.g.slime_default_config = { socket_name = "default", target_pane = ".2" }
                    print("In tmux mode")
                end
            end

            require("which-key").register({
                ["<localleader>r"] = { "Quarto Run" },
                ["<localleader>t"] = { "terminal" },
                ["<localleader>tm"] = { mark_terminal, "slime mark terminal" },
                ["<localleader>ts"] = { set_terminal, "slime set terminal" },
                ["<localleader>tt"] = { toggle_slime_tmux_nvim, "toggle tmux/nvim terminal" },
            })
        end,
    },

    {
        "neovim/nvim-lspconfig",
        ---@class PluginLspOpts
        opts = {
            servers = {
                pyright = {},
                -- r_language_server = {},
                -- julials = {},
                marksman = {
                    -- also needs:
                    -- $home/.config/marksman/config.toml :
                    -- [core]
                    -- markdown.file_extensions = ["md", "markdown", "qmd"]
                    filetypes = { "markdown", "quarto" },
                    root_dir = require("lspconfig.util").root_pattern(".git", ".marksman.toml", "_quarto.yml"),
                },
            },
        },
    },

    -- paste an image to markdown from the clipboard
    -- :PasteImg,
    {
        "dfendr/clipboard-image.nvim",
        ft = { "quarto", "markdown" },
        keys = {
            { "<leader>pi", ":PasteImg<cr>", desc = "image paste" },
        },
        cmd = {
            "PasteImg",
        },
        config = function()
            require("clipboard-image").setup({
                quarto = {
                    img_dir = "img",
                    affix = "![](%s)",
                },
            })
        end,
    },

    -- preview equations
    {
        "jbyuki/nabla.nvim",
        ft = { "quarto", "tex", "markdown" },
        keys = {
            { "<leader>pe", ':lua require"nabla".toggle_virt()<cr>', desc = "toggle equations" },
            { "<leader>ph", ':lua require"nabla".popup()<cr>', desc = "hover equation" },
        },
    },

    -- {
    --   "benlubas/molten-nvim",
    --   build = ":UpdateRemotePlugins",
    --   init = function()
    --     vim.g.molten_image_provider = "image.nvim"
    --     vim.g.molten_output_win_max_height = 20
    --     vim.g.molten_auto_open_output = false
    --   end,
    --   keys = {
    --     { "<leader>mi", ":MoltenInit<cr>",                desc = "molten init" },
    --     { "<leader>mv", ":<C-u>MoltenEvaluateVisual<cr>", mode = "v",                  desc = "molten eval visual" },
    --     { "<leader>mr", ":MoltenReevaluateCell<cr>",      desc = "molten re-eval cell" },
    --   }
    -- },
}
