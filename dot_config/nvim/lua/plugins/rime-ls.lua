--- Config for rime-ls

if _G.disable_plugins.rime then
    return {}
end

-- disable this plugin if in diff mode
if vim.wo.diff then
    return {}
end

---------------------------------------------------------------------
-- Auto disable when rime_ls is not found
---------------------------------------------------------------------
local rime_ls_exe_path = "undefined"
local rime_ls_user_dir = "undefined"
local rime_ls_shared_data_dir = "undefined"

if vim.fn.has("win32") == 1 then
    rime_ls_exe_path = vim.fn.getenv("HOME") .. "/.local/bin/rime_ls.exe"
    rime_ls_user_dir = vim.fn.getenv("HOME") .. "/.config/Rime"
    rime_ls_shared_data_dir = "C:\\Program Files (x86)\\Rime\\weasel-0.16.1\\data"
elseif vim.fn.has("mac") == 1 then
    rime_ls_exe_path = vim.fn.getenv("HOME") .. "/.local/bin/rime_ls"
    rime_ls_user_dir = vim.fn.getenv("HOME") .. "/.config/Rime"
    rime_ls_shared_data_dir = "/Library/Input Methods/Squirrel.app/Contents/SharedSupport"
end

if vim.fn.filereadable(rime_ls_exe_path) == 0 then
    return {} -- disable this plugin if rime_ls is not found
end

---------------------------------------------------------------------

local bDisableChinese = true

-- only enable space and enter when editing filename ends with '-cn'
local filename = vim.fn.expand("%:p:t:r")
if filename:sub(-3) == "-cn" then
    bDisableChinese = false
end

-- check vim modeline 'let g:rime=v:true'
-- nvim filename.md --cmd 'let g:rime=v:true'
if vim.g.rime then
    bDisableChinese = false
end

local cmp_cache = { keymaps = {}, cmp_sources = {} }

return {
    -- rime-ls
    -- https://github.com/wlh320/rime-ls

    -- cmp-lsp nvim plugin
    -- https://github.com/liubianshi/cmp-lsp-rimels
    {
        "liubianshi/cmp-lsp-rimels",
        enabled = vim.g.rime == true,
        ft = { "markdown", "org", "text" },
        dependencies = {
            "neovim/nvim-lspconfig",
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
        },
        opts = {
            cmd = { rime_ls_exe_path },
            rime_user_dir = rime_ls_user_dir,
            shared_data_dir = rime_ls_shared_data_dir,
            max_candidates = 9,
            trigger_characters = {},
            schema_trigger_character = "&", -- [since v0.2.0] 当输入此字符串时请求补全会触发 “方案选单”
            probes = {
                ignore = {},
                using = {},
                add = {},
            },
            detectors = {
                with_treesitter = {},
                with_syntax = {},
            },
            cmp_keymaps = {
                disable = {
                    space = bDisableChinese,
                    enter = bDisableChinese,
                    numbers = bDisableChinese,
                    brackets = bDisableChinese,
                    backspace = bDisableChinese,
                },
            },
        },
        keys = {
            {
                "<leader>rt",
                function()
                    vim.cmd("ToggleRime")
                    local cmp = require("cmp")
                    local sources = assert(cmp.get_config().sources, "[toggle_rime] can't get cmp_config.sources!")
                    local mapping = assert(cmp.get_config().mapping, "[toggle_rime] can't get cmp_config.mapping!")

                    -- remove conflict sources
                    local bIsChineseInputOn = false
                    local conflict_sources = { "luasnip", "dictionary", "buffer", "copilot" }
                    for i = #sources, 1, -1 do
                        for _, v in ipairs(conflict_sources) do
                            if sources[i].name == v then
                                table.insert(cmp_cache.cmp_sources, sources[i])
                                table.remove(sources, i)
                                bIsChineseInputOn = true
                                break
                            end
                        end
                    end
                    if bIsChineseInputOn then
                        print("Rime Input On 🚀")

                        -- restore cmp <Space> keymap in insert mode
                        if mapping[" "] ~= nil then
                            mapping[" "].i = cmp_cache.keymaps["<Space>i"]
                        end
                    else
                        print("Rime Input Off 💤")

                        -- refill conflict sources
                        for _, v in ipairs(cmp_cache.cmp_sources) do
                            table.insert(sources, v)
                        end
                        cmp_cache.cmp_sources = {}

                        -- disable cmp <Space> keymap in insert mode
                        if mapping[" "] ~= nil then
                            cmp_cache.keymaps["<Space>i"] = mapping[" "].i
                            mapping[" "].i = function()
                                vim.fn.feedkeys(" ", "n")
                            end
                        end
                    end
                    cmp.setup.buffer({ sources = sources })
                    cmp.setup.buffer({ mapping = mapping })
                end,
                desc = "toggle rime",
            },
            { "<leader>rs", "<cmd>RimeSync<cr>", desc = "sync rime user-data" },
        },
    },
    {
        "noearc/jieba.nvim",
        ft = { "markdown", "text" },
        dependencies = { { "noearc/jieba-lua", ft = { "markdown", "text" } } },
        keys = {
            -- stylua: ignore start
            -- { "B", mode = { "n", "x" }, function() for _ = 1,5 do require("jieba_nvim").wordmotion_B() end end, silent = true, noremap = true, },
            -- { "W", mode = { "n", "x" }, function() for _ = 1,5 do require("jieba_nvim").wordmotion_W() end end, silent = true, noremap = true, },
            -- { "E", mode = { "n", "x" }, function() for _ = 1,5 do require("jieba_nvim").wordmotion_E() end end, silent = true, noremap = true, },

            { "ciw", mode = { "n" }, function() require("jieba_nvim").change_w() end, silent = true, noremap = false, },
            { "diw", mode = { "n" }, function() require("jieba_nvim").delete_w() end, },
            { "viw", mode = { "n" }, function() require("jieba_nvim").select_w() end, },
            -- stylua: ignore end
        },
    },
}
