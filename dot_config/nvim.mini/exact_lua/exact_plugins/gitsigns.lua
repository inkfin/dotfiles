-- ~/.config/nvim.mini/lua/plugins/gitsigns.lua
-- Git signs, hunk actions, blame, and diff helpers.

require("pack").add("https://github.com/lewis6991/gitsigns.nvim")

local ok, gitsigns = pcall(require, "gitsigns")
if not ok then return end

gitsigns.setup({
    signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = ""  },
        topdelete    = { text = ""  },
        changedelete = { text = "▎" },
    },
    on_attach = function(buffer)
        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
        end

        map("n", "]h", gitsigns.next_hunk, "Next Hunk")
        map("n", "[h", gitsigns.prev_hunk, "Previous Hunk")
        map({ "n", "v" }, "<leader>ghs", "<cmd>Gitsigns stage_hunk<cr>", "Stage Hunk")
        map({ "n", "v" }, "<leader>ghr", "<cmd>Gitsigns reset_hunk<cr>", "Reset Hunk")
        map("n", "<leader>ghS", gitsigns.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gitsigns.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gitsigns.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gitsigns.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>ghb", function()
            gitsigns.blame_line({ full = true })
        end, "Blame Line")
        map("n", "<leader>ghB", gitsigns.blame, "Blame Buffer")
        map("n", "<leader>ghd", gitsigns.diffthis, "Diff This")
        map("n", "<leader>ghD", function()
            gitsigns.diffthis("~")
        end, "Diff This ~")
        map({ "n", "v" }, "<leader>ght", "<cmd>Gitsigns toggle_current_line_blame<cr>", "Toggle Current Line Blame")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select Hunk")
    end,
})

local ok_wk, wk = pcall(require, "which-key")
if ok_wk then
    wk.add({
        { "<leader>gh",  group = "+hunks"              },
        { "<leader>ghs", desc = "Stage Hunk"           },
        { "<leader>ghr", desc = "Reset Hunk"           },
        { "<leader>ghS", desc = "Stage Buffer"         },
        { "<leader>ghu", desc = "Undo Stage Hunk"      },
        { "<leader>ghR", desc = "Reset Buffer"         },
        { "<leader>ghp", desc = "Preview Hunk Inline"  },
        { "<leader>ghb", desc = "Blame Line"           },
        { "<leader>ghB", desc = "Blame Buffer"         },
        { "<leader>ghd", desc = "Diff This"            },
        { "<leader>ghD", desc = "Diff This ~"          },
        { "<leader>ght", desc = "Toggle Line Blame"    },
    })
end
