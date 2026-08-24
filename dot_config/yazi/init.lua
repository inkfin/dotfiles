-- Plugins are pinned in package.toml and managed by `ya pkg`.
-- On a new machine, run `ya pkg install` first.

require("git"):setup {}

require("smart-enter"):setup {}

require("full-border"):setup({
	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
	type = ui.Border.ROUNDED,
})

require("bookmarks"):setup({
	last_directory = { enable = true, persist = false },
	persist = "vim",
	file_pick_mode = "parent",
	show_keys = true,
	notify = {
		enable = true,
		timeout = 1,
		message = {
			new = "New bookmark '<key>' -> '<folder>'",
			delete = "Deleted bookmark in '<key>'",
			delete_all = "Deleted all bookmarks",
		},
	},
})
