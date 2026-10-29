# nvim.mini Rime regression checks

Run from the chezmoi source root:

```sh
NVIM_LOG_FILE=/tmp/nvim-rime.log XDG_STATE_HOME=/tmp/nvim-rime-state \
  nvim --headless -u NONE -l tests/nvim/rime.lua
```

The test loads the managed source directly, without installing plugins or
starting a language server. It checks filtering, selection, raw Enter, Unicode
character extraction, temporary English mode, code/math suppression, undo and
the server's sync command. Server and interactive completion checks are separate.

With `lang.rime = true` in `~/.config/nvim.mini/lua/local.lua`, prose buffers
(markdown/quarto/org/norg/text) start with Rime enabled:

| Key | Behaviour |
| --- | --- |
| `<leader>rt`, `:ToggleRime [on\|off]` | Toggle Chinese input for this buffer |
| `<leader>rs`, `:RimeSync` | Sync Rime user data |
| Space | Accept the highlighted candidate, or the first if none is highlighted |
| `1`–`9` | Send selection to Rime; commit when it returns a single candidate |
| Enter | Keep raw input and add a space when a Rime candidate is visible |
| `[` / `]` | Insert the first / last character of the selected candidate |
| `,` / `.` / `-` / `=` | Rime paging during composition, according to the schema |
| `&` | Open the Rime scheme/options menu (requires the shared F4 binding) |
| `;f` / `;;` | Enable / disable Chinese input in Insert mode |
| `;j` | Leave Insert mode |
| `;u` | Restore the last committed input if the committed text is still before the cursor |

A space after Chinese temporarily enables English input. A space after an
ASCII word returns to Chinese; Backspace across that boundary restores the
preceding mode. Capitalized words and detected code/math regions remain English.
Chinese punctuation is committed from the selected Rime schema after Chinese
text. Leading punctuation and punctuation after ASCII remain literal.

## Chinese word motions

`plugins/jieba.lua` installs the same jieba.vim v1.0.5 used by LazyVim through
vim.pack. With `lang.rime = true`, prose buffers receive buffer-local
`w/W/e/E/b/B/ge/gE` mappings in normal, visual and operator-pending modes.
Counts and `dw` work; vim-repeat preserves `.` for these operator motions.
Changing the buffer to a code filetype removes these mappings.

Both plugins stay off runtimepath until the first word motion. Python provider
detection also waits until that point; `jieba_vim_lazy = 1` postpones dictionary
loading until Chinese is encountered. A missing provider/backend warns once and
falls back to native motions for that session. After installing the missing
dependency or finishing the one-time build, restart Neovim.

Run the installed-plugin checks and microbenchmark with:

```sh
nvim --headless -u NONE -l tests/nvim/jieba.lua
```

Measured on this Mac, 2026-10-29, five fresh processes after installation
(medians, filesystem caches warm):

| Operation | Time |
| --- | ---: |
| Register the deferred jieba plugin | 1.6 ms |
| Attach prose mappings | 0.5 ms |
| First ASCII motion, including Python/plugin startup | 89 ms |
| First Chinese motion, including dictionary initialization | 77 ms |
| 1,000 warm Chinese motions | 186 ms (0.19 ms/motion) |
| Full nvim.mini startup before these changes | 120 ms |
| Full nvim.mini startup after these changes | 115 ms |

The full-startup samples ranged from 114–126 ms before and 111–122 ms after;
this does not establish a speedup. The first test during installation took
about 3 seconds to start Python, so the 89 ms warm-cache figure is not a cold
start guarantee. First use on Chinese may pay both initialization costs.
The final vim-repeat-enabled check measured about 89 ms / 75 ms for those
stages and 186 ms for 1,000 motions. The backend's one-time source build took
22.5 seconds on this machine; it is not part of editor startup.

Prefer this on-demand loading over eager loading or idle prewarming: it keeps
Python and the dictionary out of code-only sessions. Further optimization
should be based on a measured input delay; scanning/caching entire buffers to
skip ASCII motions would add invalidation logic and can break motions that
cross into Chinese on another line.
