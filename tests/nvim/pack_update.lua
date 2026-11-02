-- Run: NVIM_LOG_FILE=/tmp/nvim-pack-test.log nvim --headless -u NONE -l tests/nvim/pack_update.lua
-- All Git operations and lockfile writes stay in a disposable directory.
local root = vim.fn.tempname()
local stdpath = vim.fn.stdpath
vim.fn.stdpath = function(kind)
    if kind == 'config' or kind == 'data' or kind == 'state' or kind == 'log' then
        return root .. '/' .. kind
    end
    return stdpath(kind)
end
local function git(...)
    local result = vim.system({ 'git', '-C', root .. '/repo', ... }, { text = true }):wait()
    assert(result.code == 0, result.stderr)
end
vim.fn.mkdir(root .. '/repo', 'p')
git('init', '-b', 'main')
git('-c', 'user.name=Test', '-c', 'user.email=test@example.invalid',
    'commit', '--allow-empty', '-m', 'fixture')
vim.opt.packpath:prepend(root .. '/data/site')
vim.pack.add({ { src = 'file://' .. root .. '/repo', name = 'fixture' } }, { confirm = false, load = false })

local native_update = vim.pack.update
local run_list_index, run_list
for i = 1, 100 do
    local name, value = debug.getupvalue(native_update, i)
    if name == 'run_list' then run_list_index, run_list = i, value; break end
    if not name then break end
end
assert(run_list_index, 'native update seam changed; revise this regression test')
-- Reproduce the exact report failure with revision collection left incomplete.
debug.setupvalue(native_update, run_list_index, function() end)
local ok, err = pcall(native_update, nil, { offline = true })
assert(not ok and tostring(err):find("field 'sha_target' (a nil value)", 1, true), tostring(err))
print('PASS native incomplete-revision repro: ' .. tostring(err))

local notifications = {}
vim.notify = function(message, level)
    notifications[#notifications + 1] = { message = message, level = level }
end
dofile(vim.env.PACK_EXT_SOURCE or 'dot_config/nvim.mini/exact_lua/exact_plugins/pack_ext.lua')
local calls = 0
vim.pack.update = function(...)
    assert(select('#', ...) == 0, 'must preserve default fetch and confirmation options')
    calls = calls + 1
    if calls == 2 then debug.setupvalue(native_update, run_list_index, run_list) end
    return native_update(nil, { offline = true })
end
vim.cmd.PackUpdate()
assert(calls == 2, 'expected one recovery attempt')
local report = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
assert(report:find('fixture', 1, true) and report:find('Revision:', 1, true), report)
print('PASS recovered native confirmation report')

for _, message in ipairs({ "attempt to concatenate field 'sha_target' (a nil value)", 'fetch failed' }) do
    calls = 0
    vim.pack.update = function() calls = calls + 1; error(message) end
    vim.cmd.PackUpdate()
    assert(calls == (message == 'fetch failed' and 1 or 2), 'incorrect retry limit')
    assert(notifications[#notifications].level == vim.log.levels.ERROR)
end
print('PASS persistent failure and unrelated errors are reported')
calls = 0
vim.pack.update = function() calls = calls + 1; vim.cmd.PackUpdate() end
vim.cmd.PackUpdate()
assert(calls == 1, 'reentrant update was allowed')
print('PASS reentrant updates blocked and guard resets after failure')
vim.fn.delete(root, 'rf')
