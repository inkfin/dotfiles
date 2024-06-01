local wezterm = require("wezterm")

local module = {}

function module.merge_table(t1, t2)
	for k, v in pairs(t2) do
		if type(v) == "table" and next(v) ~= nil then
			if type(t1[k] or false) == "table" then
				module.merge_table(t1[k] or {}, t2[k] or {})
			else
				t1[k] = v
			end
		elseif v ~= nil then
			t1[k] = v
		end
	end
end

function module.require_config(require_name)
	local conf = require(require_name)
	module.merge_table(Config, conf)
end

function module.os(platform)
	local platform_name = ""
	if platform == "windows" then
		platform_name = "x86_64-pc-windows-msvc"
	elseif platform == "macos" then
		platform_name = "x86_64-apple-darwin"
	elseif platform == "linux" then
		platform_name = "x86_64-unknown-linux-gnu"
	end
	return wezterm.target_triple == platform_name
end

function module.add_key(key)
	if Config.keys == nil then
		Config.keys = {}
	end
	table.insert(Config.keys, key)
end

return module
