" project config loader

function! projectloader#LoadSettings()
    let l:config_file = getcwd() . "/.vim/projectsettings.vim"
        if filereadable(l:config_file)
            execute "source " . l:config_file
                echo "Loaded project settings from " . l:config_file
        endif
endfunction

augroup ProjectSettings
        autocmd!
            autocmd VimEnter,DirChanged * call projectloader#LoadSettings()
augroup END

command! LoadProjectSettings call projectloader#LoadSettings()
