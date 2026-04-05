-- ~/.config/nvim.mini/lua/plugins/which-key.lua
-- which-key.nvim: keymap popup + group labels

require("pack").add("https://github.com/folke/which-key.nvim")

local ok, wk = pcall(require, "which-key")
if not ok then return end

wk.setup({
    preset = "helix",
    delay  = 300,
    win = {
        border = "rounded",
    },
    keys = {
        scroll_down = "<C-d>",
        scroll_up   = "<C-u>",
    },
})

-- Top-level group labels
wk.add({
    { "<leader>b",  group = "+buffer"   },
    { "<leader>c",  group = "+code"     },
    { "<leader>f",  group = "+find"     },
    { "<leader>g",  group = "+git"      },
    { "<leader>p",  group = "+pack"     },
    { "<leader>r",  group = "+refactor" },
    { "<leader>s",  group = "+search"   },
    { "<leader>t",  group = "+tab"      },
    { "<leader>u",  group = "+ui"       },
    { "<leader>y",  group = "+yazi"     },
})
