" projectloader.vim

let s:last_loaded = {}
" s:last_loaded = {
"   'cwd': '...',
"   'mtime': 123456789
" }

function! projectloader#LoadSettings() abort
    let l:file = getcwd() .. '/.vim/projectsettings.vim'
    if !filereadable(l:file)
        return
    endif

    let l:mtime = getftime(l:file)
    if get(s:last_loaded, 'cwd', '') ==# getcwd() && get(s:last_loaded, 'mtime', -1) ==# l:mtime
        " same cwd and unchanged file
        return
    endif

    execute 'silent source' fnameescape(l:file)
    let s:last_loaded = {'cwd': getcwd(), 'mtime': l:mtime}

    echo 'Loaded project settings from ' .. l:file
endfunction

augroup ProjectSettings
    autocmd!
    autocmd VimEnter,DirChanged * call projectloader#LoadSettings()
augroup END

command! LoadProjectSettings call projectloader#LoadSettings()
