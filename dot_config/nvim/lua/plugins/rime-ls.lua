return {
    -- rime-ls
    -- https://github.com/wlh320/rime-ls

    -- cmp-lsp nvim plugin
    -- https://github.com/liubianshi/cmp-lsp-rimels
    {
        "liubianshi/cmp-lsp-rimels",
        ft = { "markdown", "text" },
        dependencies = {
            "neovim/nvim-lspconfig",
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            -- only enable space and enter when editing filename ends with '-cn'
            local bDisableChinese = true

            local filename = vim.fn.expand("%:p:t:r")
            if filename:sub(-3) == "-cn" then
                bDisableChinese = false
            end
            local M = {}
            if vim.fn.has("win32") == 1 then
                M.cmd = { vim.fn.getenv("HOME") .. "/.local/bin/rime_ls.exe" }
                M.rime_user_dir = vim.fn.getenv("HOME") .. "/.config/Rime"
                M.shared_data_dir = vim.fn.getenv("APPDATA") .. "/rime-ls/"
            elseif vim.fn.has("mac") == 1 then
                M.cmd = { "rime_ls" }
                M.rime_user_dir = "~/.config/Rime"
                M.shared_data_dir = "/Library/Input Methods/Squirrel.app/Contents/SharedSupport"
            end

            M.max_candidates = 9
            M.trigger_characters = {}
            M.schema_trigger_character = "&" -- [since v0.2.0] 当输入此字符串时请求补全会触发 “方案选单”
            M.probes = {
                ignore = {},
                using = {},
                add = {},
            }
            M.detectors = {
                with_treesitter = {},
                with_syntax = {},
            }
            M.cmp_keymaps = {
                disable = {
                    space = bDisableChinese,
                    enter = bDisableChinese,
                    numbers = bDisableChinese,
                    brackets = bDisableChinese,
                    backspace = bDisableChinese,
                },
            }
            require("rimels").setup(M)
        end,
        keys = {
            {
                "<leader>rt",
                function()
                    vim.cmd("ToggleRime")
                    local cmp = require("cmp")
                    local sources = assert(cmp.get_config().sources)
                    local bHasDictionary = false
                    for i = #sources, 1, -1 do
                        if sources[i].name == "dictionary" then
                            table.remove(sources, i)
                            bHasDictionary = true
                        elseif sources[i].name == "copilot" then
                            table.remove(sources, i)
                            bHasDictionary = true
                        end
                    end
                    if not bHasDictionary then
                        print("Rime Input Off 💤")
                        table.insert(sources, { name = "copilot" })
                        table.insert(sources, { name = "dictionary" })
                    else
                        print("Rime Input On 🚀")
                    end
                    cmp.setup.buffer({ sources = sources })
                end,
                desc = "toggle rime",
            },
            { "<leader>rs", "<cmd>RimeSync<cr>", desc = "sync rime user-data" },
        },
    },
}
