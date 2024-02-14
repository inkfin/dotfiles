-- Auto complete plugin

return {
    -- Use <tab> for completion and snippets (supertab)
    -- first: disable default <tab> and <s-tab> behavior in LuaSnip
    {
        "L3MON4D3/LuaSnip",
        keys = function()
            return {}
        end,
    },
    -- then: setup supertab in cmp
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            { "hrsh7th/cmp-emoji" },
            {
                "uga-rosa/cmp-dictionary",
                opts = {
                    paths = { vim.fn.stdpath("config") .. "/spell/en.dict" },
                    exact_length = 2,
                    first_case_insenstive = false,
                },
            },
        },
        opts = function(_, opts)
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

            opts.completion.completeopt = "menu,menuone" --,noinsert,noselect

            opts.mapping = cmp.mapping.preset.insert({
                -- changing scrolling keymap from <C-b/f> to <C-u/d>
                ["<C-u>"] = cmp.mapping.scroll_docs(-4), -- Up
                ["<C-d>"] = cmp.mapping.scroll_docs(4), -- Down
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
            })
            opts.sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "emoji" },
                { name = "luasnip" },
                { name = "path" },
                { name = "copilot" },
                { name = "buffer" },
            }, {
                { name = "buffer" },
                { name = "dictionary", keyword_length = 2 },
            })
            opts.formatting = {
                format = function(entry, item)
                    local icons = require("lazyvim.config").icons.kinds
                    if icons[item.kind] then
                        item.kind = icons[item.kind] .. item.kind
                    end
                    -- item.menu = ({
                    --     nvim_lsp = "[LSP]",
                    --     emoji = "[Emoji]",
                    --     luasnip = "[LuaSnip]",
                    --     nvim_lua = "[Lua]",
                    --     latex_symbols = "[LaTeX]",
                    --     path = "[Path]",
                    --     copilot = "[AI]",
                    --     buffer = "[Buffer]",
                    --     dictionary = "[Dict]",
                    -- })[entry.source.name]
                    return item
                end,
            }
        end,
    },
}
