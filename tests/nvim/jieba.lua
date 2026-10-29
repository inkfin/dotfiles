-- Requires the pinned jieba.vim installed in this NVIM_APPNAME's vim.pack tree.
-- nvim --headless -u NONE -l tests/nvim/jieba.lua
package.loaded['local'] = { lang = { rime = true } }
package.loaded.pack = dofile('dot_config/nvim.mini/exact_lua/pack.lua')
package.preload['plugins.jieba'] = function()
    return dofile('dot_config/nvim.mini/exact_lua/exact_plugins/jieba.lua')
end
local uv = vim.uv
local timings = {}
local function timed(name, fn)
    local start = uv.hrtime()
    fn()
    timings[name] = (uv.hrtime() - start) / 1e6
end
local function feed(keys)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), 'xt', false)
end
local function line(text)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {text})
    vim.api.nvim_win_set_cursor(0, {1, 0})
end
local function col() return vim.api.nvim_win_get_cursor(0)[2] end
-- Startup baseline loads the same plugin manager as nvim.mini.
timed('registration_ms', function() package.loaded.pack.load({'plugins.jieba'}) end)
assert(vim.g.loaded_jieba_vim == nil, 'jieba was sourced eagerly')
assert(not vim.o.rtp:find('/jieba.vim', 1, true), 'deferred plugin leaked into runtimepath')
vim.bo.filetype = 'lua'
assert(vim.fn.maparg('w', 'n') == '', 'code buffer has a jieba mapping')
timed('prose_attach_ms', function() vim.bo.filetype = 'markdown' end)
assert(vim.g.loaded_jieba_vim == nil, 'FileType started Python/jieba')
for _, mode in ipairs({'n', 'x', 'o'}) do
    for _, motion in ipairs({'w', 'W', 'e', 'E', 'b', 'B', 'ge', 'gE'}) do
        assert(vim.fn.maparg(motion, mode, false, true).buffer == 1)
    end
end
line('hello world again')
timed('first_ascii_motion_ms', function() feed('w') end)
assert(vim.g.loaded_jieba_vim == 1, 'first motion did not load jieba')
assert(col() == 6, 'ASCII motion failed')
line('你好世界欢迎使用中文分词')
timed('first_chinese_motion_ms', function() feed('w') end)
assert(col() == #'你好', 'Chinese segmentation failed: ' .. col())
feed('b')
assert(col() == 0)
feed('2w')
assert(col() == #'你好世界', 'count was not preserved')
line('你好世界欢迎使用中文分词')
feed('dw')
assert(vim.api.nvim_get_current_line() == '世界欢迎使用中文分词', 'operator-pending motion failed')
feed('.')
assert(vim.api.nvim_get_current_line() == '欢迎使用中文分词', 'dot-repeat lost Chinese motion')
line('你好世界欢迎使用中文分词')
feed('ve')
assert(col() == #'你', 'visual word end failed')
feed('<Esc>')
line('你好世界欢迎使用中文分词')
timed('warm_1000_motions_ms', function()
    for _ = 1, 500 do feed('w'); feed('b') end
end)
-- Remove mappings on FileType changes and leave other buffers/global maps alone.
vim.bo.filetype = 'lua'
assert(vim.fn.maparg('w', 'n') == '', 'stale mapping after FileType change')
vim.cmd.enew()
assert(vim.fn.maparg('w', 'n') == '', 'global motion leaked')
assert(vim.g.jieba_vim_keymap == 0)
print('PASS lazy registration, buffer isolation, Chinese/ASCII/count/operator/visual motions')
print(vim.json.encode(timings))
