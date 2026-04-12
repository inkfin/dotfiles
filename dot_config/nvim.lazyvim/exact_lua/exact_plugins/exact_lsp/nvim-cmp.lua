-- Auto complete plugin

return {
    -- Clear default LuaSnip tab keys — Tab/S-Tab are handled via cmp mapping below.
    -- (lazyvim.plugins.extras.coding.luasnip sets <tab>/<s-tab> in "s" mode;
    --  returning {} here prevents double-binding)
    {
        "L3MON4D3/LuaSnip",
        keys = function()
            return {}
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            { "hrsh7th/cmp-emoji" },
        },
        init = function()
            -- Use nvim_create_user_command so we don't need to pollute _G
            vim.api.nvim_create_user_command("AutoCmpOn", function()
                require("cmp").setup({
                    completion = {
                        autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged },
                    },
                })
            end, { desc = "Enable auto completion popup" })
            vim.api.nvim_create_user_command("AutoCmpOff", function()
                require("cmp").setup({
                    completion = { autocomplete = false },
                })
            end, { desc = "Disable auto completion popup" })
        end,
        opts = function(_, opts)
            local luasnip = require("luasnip")
            local cmp = require("cmp")

            -- no preselect
            local auto_select = false
            opts.completion.completeopt = "menu,menuone" .. (auto_select and "" or ",noselect")
            opts.preselect = auto_select and cmp.PreselectMode.Item or cmp.PreselectMode.None

            opts.mapping = cmp.mapping.preset.insert({
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-\\>"] = cmp.mapping.complete(),
                -- scroll docs with <C-u/d> (mirrors noice.lsp scroll bindings)
                ["<C-u>"] = cmp.mapping.scroll_docs(-4),
                ["<C-d>"] = cmp.mapping.scroll_docs(4),
                ["<C-e>"] = cmp.mapping.abort(),
                -- LazyVim.cmp.confirm: creates undo point, only fires when popup visible
                ["<CR>"] = LazyVim.cmp.confirm({ select = auto_select }),
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        if #cmp.get_entries() == 1 then
                            cmp.confirm({ select = true })
                        else
                            cmp.select_next_item()
                        end
                    elseif luasnip.locally_jumpable(1) then
                        luasnip.jump(1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<S-Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.locally_jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { "i", "s" }),
            })

            -- NOTE: "luasnip" must stay in group 1 here — the rime-ls toggle
            -- (see rime-ls.lua <leader>rt) reads cmp.get_config().sources and
            -- removes "luasnip" from the live list when Chinese input is active.
            opts.sources = cmp.config.sources({
                { name = "luasnip" },
                { name = "nvim_lsp" },
                { name = "emoji" },
            })

            local compare = require("cmp.config.compare")

            -- Detect whether a cmp entry originates from rime_ls
            local function is_rime_entry(entry)
                if not entry or entry.source.name ~= "nvim_lsp" then
                    return false
                end
                local ok, client_name = pcall(function()
                    return entry.source.source.client.name
                end)
                return ok and client_name == "rime_ls"
            end

            -- When both entries come from rime_ls, respect rime's candidate order
            -- (rime-ls sets sortText to "z001", "z002", …). When only one entry is
            -- from rime, always sort rime entries before others so that the numbered
            -- candidates stay at the top of the menu.
            local function rime_comparator(entry1, entry2)
                local r1 = is_rime_entry(entry1)
                local r2 = is_rime_entry(entry2)
                if r1 and r2 then
                    -- both rime: sort by sortText (guaranteed set by rime-ls)
                    local st1 = entry1.completion_item.sortText or ""
                    local st2 = entry2.completion_item.sortText or ""
                    if st1 < st2 then return true end
                    if st1 > st2 then return false end
                    return nil
                elseif r1 then
                    return true  -- rime entry first
                elseif r2 then
                    return false -- rime entry first
                end
                return nil -- neither is rime, fall through
            end

            opts.sorting = {
                priority_weight = 2,
                comparators = {
                    rime_comparator, -- pin rime candidates to rime's own order
                    compare.offset,
                    compare.exact,
                    compare.score,
                    compare.recently_used,
                    compare.kind,
                    compare.length,
                    compare.sort_text,
                    compare.order,
                },
            }
        end,
        -- stylua: ignore
        keys = {
            { "<C-x><C-o>", mode = { "i" }, function() require("cmp").complete() end, desc = "Trigger cmp complete" },
        },
    },
}
