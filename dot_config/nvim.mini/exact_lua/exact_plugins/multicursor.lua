-- ~/.config/nvim.mini/lua/plugins/multicursor.lua
-- multicursor.nvim: multi-cursor editing

require("pack").add("https://github.com/jake-stewart/multicursor.nvim")

local ok, mc = pcall(require, "multicursor-nvim")
if not ok then return end
local set = vim.keymap.set

mc.setup()

-- Add / skip cursor above or below main cursor
set({ "n", "x" }, "<M-up>",   function() mc.lineAddCursor(-1)  end, { desc = "Add cursor above" })
set({ "n", "x" }, "<M-down>", function() mc.lineAddCursor(1)   end, { desc = "Add cursor below" })
set({ "n", "x" }, "<up>",     function() mc.lineSkipCursor(-1) end, { desc = "Skip cursor up"   })
set({ "n", "x" }, "<down>",   function() mc.lineSkipCursor(1)  end, { desc = "Skip cursor down" })

-- Add / skip cursor by matching word or selection
set({ "n", "x" }, "gl",  function() mc.matchAddCursor(1)   end, { desc = "MC: match add →"  })
set({ "n", "x" }, "g>",  function() mc.matchSkipCursor(1)  end, { desc = "MC: match skip →" })
set({ "n", "x" }, "gL",  function() mc.matchAddCursor(-1)  end, { desc = "MC: match add ←"  })
set({ "n", "x" }, "g<",  function() mc.matchSkipCursor(-1) end, { desc = "MC: match skip ←" })

-- Mouse cursors (Alt + left-click)
set("n", "<M-leftmouse>",   mc.handleMouse)
set("n", "<M-leftdrag>",    mc.handleMouseDrag)
set("n", "<M-leftrelease>", mc.handleMouseRelease)

-- Toggle enable/disable all cursors
set({ "n", "x" }, "<leader>ac", mc.toggleCursor, { desc = "MC: toggle cursors" })

-- Layer: these mappings only activate when multiple cursors exist
mc.addKeymapLayer(function(layerSet)
    layerSet({ "n", "x" }, "<left>",      mc.prevCursor,   { desc = "MC: prev cursor"   })
    layerSet({ "n", "x" }, "<right>",     mc.nextCursor,   { desc = "MC: next cursor"   })
    layerSet({ "n", "x" }, "<leader>ad",  mc.deleteCursor, { desc = "MC: delete cursor" })
    layerSet("n", "<esc>", function()
        if not mc.cursorsEnabled() then
            mc.enableCursors()
        else
            mc.clearCursors()
        end
    end, { desc = "MC: enable / clear" })
end)

-- Cursor highlight groups
local hl = vim.api.nvim_set_hl
hl(0, "MultiCursorCursor",          { reverse = true })
hl(0, "MultiCursorVisual",          { link = "Visual"      })
hl(0, "MultiCursorSign",            { link = "SignColumn"   })
hl(0, "MultiCursorMatchPreview",    { link = "Search"       })
hl(0, "MultiCursorDisabledCursor",  { reverse = true })
hl(0, "MultiCursorDisabledVisual",  { link = "Visual"      })
hl(0, "MultiCursorDisabledSign",    { link = "SignColumn"   })
