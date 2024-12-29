-- install
-- ya pack -a yazi-rs/plugins:git
-- ya pack -a yazi-rs/plugins:smart-enter
-- ya pack -a yazi-rs/plugins:max-preview
-- ya pack -a yazi-rs/plugins:full-border

require("git"):setup()
require("full-border"):setup({
	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
	type = ui.Border.ROUNDED,
})
