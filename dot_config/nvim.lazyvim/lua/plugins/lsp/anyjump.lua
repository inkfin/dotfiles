-- simple and solid any-jump with only rg
return {
    "pechorin/any-jump.vim",
    init = function()
        -- Show line numbers in search results
        vim.g.any_jump_list_numbers = 0

        -- Auto group results by filename
        -- vim.g.any_jump_grouping_enabled = 1

        -- Search references only for current file type
        vim.g.any_jump_references_only_for_current_filetype = 1

        -- Disable search engine ignore vcs untracked files
        vim.g.any_jump_disable_vcs_ignore = 0

        -- Custom ignore files
        vim.g.any_jump_ignored_files = { "*.tmp", "*.temp", "*.log", "*.bak", "*.swp" }
    end,
}
