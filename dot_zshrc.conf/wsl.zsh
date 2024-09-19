# -*- zsh -*-
# vi: ft=zsh

# ======================================
#  wsl.zsh
# ======================================
#   wsl related config
# ======================================


# ==== Aliases ====

# wsl2
alias wopen="explorer.exe"
function wcd() {
    if [ "$#" -ne 1 ]; then
        cd "$@"
    elif [[ "$1" =~ '\\' ]]; then
        path=$(wslpath "$1")
        cd "$(realpath "$path")"
    else
        cd "$(realpath "$1")"
    fi
}

