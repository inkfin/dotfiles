return {
    "inkfin/ticktick.nvim",
    branch = "all-in-one",
    build = "uv tool install -e .",
    opts = {
        keymaps = true,
    },
    keys = {
        { "<leader>tt", "<cmd>Ticktick<cr>", desc = "TickTick" },
    },
}
