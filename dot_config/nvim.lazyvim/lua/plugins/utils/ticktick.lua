return {
    "inkfin/ticktick.nvim",
    branch = "all-in-one",
    build = "uv tool install -e .",
    enabled = not _G.disable_plugins.ticktick,
    opts = {
        keymaps = true,
    },
    keys = {
        { "<leader>tt", "<cmd>Ticktick<cr>", desc = "TickTick" },
    },
}
