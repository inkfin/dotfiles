if _G.disable_plugins.flash then
    return {}
end

return {
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        ---@type Flash.Config
        opts = {
            modes = {
                char = {
                    enabled = false,
                },
                search = {
                    enabled = false,
                },
            },
        },
        -- stylua: ignore
        keys = {
            { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
            { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
            { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
            { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
            { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
            { "t", mode = { "n", "x", "o" }, function()
                require("flash").jump({
                    matcher = function(win)
                        ---@param diag Diagnostic
                        return vim.tbl_map(function(diag)
                        return {
                            pos = { diag.lnum + 1, diag.col },
                            end_pos = { diag.end_lnum + 1, diag.end_col - 1 },
                        }
                        end, vim.diagnostic.get(vim.api.nvim_win_get_buf(win)))
                    end,
                    action = function(match, state)
                        vim.api.nvim_win_call(match.win, function()
                        vim.api.nvim_win_set_cursor(match.win, match.pos)
                        vim.diagnostic.open_float()
                        end)
                        state:restore()
                    end,
                }) end, desc = "Flash show diagnostic" },
        },
    },
    {
        -- This will allow you to use s in normal mode and <c-s> in insert mode, to jump to a label in Telescope results.
        "nvim-telescope/telescope.nvim",
        optional = true,
        opts = function(_, opts)
            local function flash(prompt_bufnr)
                require("flash").jump({
                    pattern = "^",
                    label = { after = { 0, 0 } },
                    search = {
                        mode = "search",
                        exclude = {
                            function(win)
                                return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
                            end,
                        },
                    },
                    action = function(match)
                        local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
                        picker:set_selection(match.pos[1] - 1)
                    end,
                })
            end
            opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
                mappings = {
                    n = { s = flash },
                    i = { ["<c-s>"] = flash },
                },
            })
        end,
    },
}
