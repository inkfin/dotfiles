return {
    -- tutorials: https://github.com/stevearc/overseer.nvim/blob/master/doc/tutorials.md
    {
        "stevearc/overseer.nvim",
        keys = {
            { "<leader>or", "<cmd>OverseerRun<cr>", desc = "Overseer Run" },
            { "<leader>oa", "<cmd>OverseerQuickAction<cr>", desc = "Overseer Quick Actions" },
        },
        config = {
            templates = { "builtin", "cpp.build_single_file" },
        },
        opts = function(_, opts)
            --  to stop watching the file use the "dispose" action from :OverseerQuickAction.
            vim.api.nvim_create_user_command("WatchRun", function()
                local overseer = require("overseer")
                overseer.run_template({ name = "run script" }, function(task)
                    if task then
                        task:add_component({ "restart_on_save", paths = { vim.fn.expand("%:p") } })
                        local main_win = vim.api.nvim_get_current_win()
                        overseer.run_action(task, "open vsplit")
                        vim.api.nvim_set_current_win(main_win)
                    else
                        vim.notify("WatchRun not supported for filetype " .. vim.bo.filetype, vim.log.levels.ERROR)
                    end
                end)
            end, {})
        end,
    },
}
