-- mux.lua
-- Multiplexing: SSH domains + workspace configuration
local wezterm = require("wezterm")
local t = require("tools")
local config = {}

-- SSH domains for remote servers
config.ssh_domains = {
	{
		name = "aliyun",
		remote_address = "inkfin.xyz",
		username = "inkfin",
	},
}

-- Forward SSH agent through multiplexer
config.mux_enable_ssh_agent = true

-- Persistence: daemon mode keeps mux alive after GUI closes
-- Uncomment to enable background mux server
-- config.daemon_options = {}

return config
