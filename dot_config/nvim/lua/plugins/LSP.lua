-- LSP customizations, see https://www.lazyvim.org/plugins/lsp#%EF%B8%8F-customizing-lsp-keymaps for more details.
return {
    {
        "neovim/nvim-lspconfig",
        init = function()
            local keys = require("lazyvim.plugins.lsp.keymaps").get()
            -- cancel K from hover
            keys[#keys + 1] = { "K", false }
            -- cancel <leader>cr from rename
            keys[#keys + 1] = { "<leader>cr", false }
            keys[#keys + 1] = { "<leader>rn", vim.lsp.buf.rename, desc = "rename", mode = { "n" } }
            -- unmap <leader>cl from Lsp Info
            keys[#keys + 1] = { "<leader>cl", false }
            keys[#keys + 1] = { "<leader>uL", "<Cmd>LspInfo<CR>", desc = "Lsp Info", mode = { "n" } }
            -- map <leader>cl
            keys[#keys + 1] = { "<leader>cl", vim.lsp.codelens.run, desc = "codelens", mode = { "n" } }
        end,
    },
    {
        "L3MON4D3/LuaSnip",
    },
    {
        "hrsh7th/nvim-cmp",
        version = false,
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "saadparwaiz1/cmp_luasnip",
        },
        opts = function()
            local has_words_before = function()
                unpack = unpack or table.unpack
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0
                    and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
            end

            -- luasnip setup
            local luasnip = require("luasnip")
            -- nvim-cmp setup
            local cmp = require("cmp")

            return {
                completion = {
                    completeopt = "menu,menuone,noinsert",
                },
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4), -- Up
                    ["<C-f>"] = cmp.mapping.scroll_docs(4), -- Down
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        elseif has_words_before() then
                            cmp.complete()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = {
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                    { name = "copilot" },
                },
                experimental = {
                    ghost_text = {
                        hl_group = "LspCodeLens",
                    },
                },
            }
        end,
    },
}
