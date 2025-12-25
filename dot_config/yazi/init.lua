-- install
-- ya pack -a yazi-rs/plugins:smart-enter

---Load plugins
---@param name string @plugin name
---@param remote string @remote package source
---@param opts table @setup options
---@param nosetup boolean? @if true, do not load the plugin
local function safe_load_plugins(name, remote, opts, nosetup)
	local success, module = pcall(require, name)
	if success then
        if not nosetup then
            module:setup(opts)
        end
	else
		print("Failed to load " .. name .. " module.\nTrying to install with: `ya pack -a " .. remote)
		local ret = os.execute("ya pack -a " .. remote)
		print("finish, ret:", ret)
	end
end

safe_load_plugins("git", "yazi-rs/plugins:git", {})

safe_load_plugins("smart-enter", "yazi-rs/plugins:smart-enter", {})

safe_load_plugins("toggle-pane", "yazi-rs/plugins:toggle-pane", {}, true)

safe_load_plugins("full-border", "yazi-rs/plugins:full-border", {
    -- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
    type = ui.Border.ROUNDED,
})

safe_load_plugins("bookmarks", "dedukun/bookmarks", {
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
