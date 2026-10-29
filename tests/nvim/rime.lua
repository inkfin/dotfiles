-- Run: nvim --headless -u NONE -l tests/nvim/rime.lua
package.path = './dot_config/nvim.mini/exact_lua/?.lua;' .. package.path
package.loaded['local'] = { lang = { rime = true } }
vim.inspect_pos = function() return { treesitter = {}, syntax = {} } end
package.loaded.lsp_util = { setup = function() end, enable = function() end }
local rime = dofile('dot_config/nvim.mini/exact_lua/exact_lang/rime.lua')
rime.available = function() return true end
local failures = {}
local function check(name, fn)
    local ok, err = pcall(fn)
    print((ok and 'PASS ' or 'FAIL ') .. name)
    if not ok then table.insert(failures, name .. ': ' .. tostring(err)) end
end
local chinese = { client_name = 'rime_ls', label = '你好', filterText = 'nihao', textEdit = { newText = '你好' } }
local english = { client_name = 'marksman', label = 'link' }
local function filter(line, enabled)
    vim.b.rime_enabled = enabled
    return rime.blink_sources().providers.lsp.transform_items({ bufnr = 0, line = line, cursor = { 1, #line } }, { chinese, english })
end
check('off removes Chinese candidates', function() assert(vim.deep_equal(filter('nihao', false), { english })) end)
check('schema menu survives filtering', function() assert(vim.deep_equal(filter('&', true), { chinese })) end)
check('punctuation alone stays literal', function() assert(vim.deep_equal(filter('+', true), { english })) end)
check('Chinese composition excludes other LSP items', function() assert(vim.deep_equal(filter('nihao', true), { chinese })) end)
local list = { items = { chinese, vim.tbl_extend('force', chinese, { label = '您好' }) } }
package.loaded['blink.cmp.completion.list'] = list
package.loaded['blink.cmp.completion.windows.menu'] = { win = { is_open = function() return true end } }
local accepted
local cmp = {
    accept = function(opts) accepted = opts.index; return true end,
    get_selected_item_idx = function() return 2 end,
    cancel = function() return true end,
    hide = function() return true end,
}
vim.b.rime_enabled = true
vim.api.nvim_buf_set_lines(0, 0, -1, false, { 'nihao ' })
vim.api.nvim_win_set_cursor(0, { 1, 5 })
local keys = rime.blink_keymaps()
check('space respects selected candidate', function() keys['<Space>'][1](cmp); assert(accepted == 2) end)
check('brackets and raw Enter are mapped', function() assert(keys['['] and keys[']'] and keys['<CR>']) end)
check('sync uses server command', function()
    local command
    local get_clients = vim.lsp.get_clients
    vim.lsp.get_clients = function() return {{ request = function(_, _, params) command = params.command end }} end
    rime.sync()
    vim.lsp.get_clients = get_clients
    assert(command == 'rime-ls.sync-user-data', tostring(command))
end)
check('brackets select UTF-8 first and last characters', function()
    for key, expected in pairs({ ['['] = '你', [']'] = '好' }) do
        list.items[2] = vim.deepcopy(chinese)
        keys[key][1](cmp)
        assert(list.items[2].textEdit.newText == expected)
        assert(chinese.textEdit.newText == '你好')
    end
end)
check('Enter cancels rather than accepting Chinese', function()
    local cancelled = false
    cmp.cancel = function(opts) cancelled = opts.callback ~= nil; return true end
    accepted = nil
    assert(keys['<CR>'][1](cmp))
    assert(cancelled and accepted == nil)
end)
check('digits reach Rime for learning and schema selection', function()
    assert(keys['2'][1](cmp) == '2')
end)
check('digits fall through when Rime is off', function()
    vim.b.rime_enabled = false
    assert(keys['2'][1](cmp) == false)
    vim.b.rime_enabled = true
end)
check('Chinese punctuation is eligible, ASCII punctuation is not', function()
    assert(rime.punctuation_context('你好,', #'你好,'))
    assert(not rime.punctuation_context('hello,', #'hello,'))
    assert(vim.deep_equal(filter('你好,', true), { chinese }))
end)
check('temporary English restores normal completion providers', function()
    vim.b.rime_ascii = true
    assert(#rime.blink_sources().default() == 4)
    assert(vim.deep_equal(filter('hello', true), { english }))
    vim.b.rime_ascii = false
    assert(vim.deep_equal(rime.blink_sources().default(), { 'lsp' }))
    assert(#rime.blink_sources().providers.lsp.fallbacks() == 0)
end)
check('code and math captures suppress Chinese', function()
    for _, capture in ipairs({ 'markup.raw.block', 'markup.math' }) do
        vim.inspect_pos = function() return { treesitter = {{ capture = capture }}, syntax = {} } end
        assert(vim.deep_equal(filter('nihao', true), { english }))
    end
    vim.inspect_pos = function() return { treesitter = {}, syntax = {} } end
end)
check('undo restores only the committed text', function()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { '前你好 ' })
    vim.api.nvim_win_set_cursor(0, { 1, #'前你好' })
    vim.b.rime_last_commit = { row = 1, text = '你好', input = 'nihao' }
    assert(rime.undo() == '')
    assert(vim.wait(100, function() return vim.api.nvim_get_current_line() == '前nihao ' end))
    assert(rime.undo() == ';u')
end)
if #failures > 0 then error(table.concat(failures, '\n')) end
