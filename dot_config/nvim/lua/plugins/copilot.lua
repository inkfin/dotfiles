if _G.disable_plugins.copilot then
    return {}
end

return {
    {
        "zbirenbaum/copilot.lua",
        keys = {
            { "<leader>cD", "<cmd>Copilot disable<CR>", mode = "n", desc = "Disable Copilot" },
            { "<leader>cE", "<cmd>Copilot enable<CR>", mode = "n", desc = "Enable Copilot" },
        },
        opts = {
            suggestion = { enabled = false },
            panel = { enabled = false },
            filetypes = {
                markdown = true,
            },
        },
    },
}
