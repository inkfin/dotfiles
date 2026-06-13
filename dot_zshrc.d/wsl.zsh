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
        local wsl_path
        wsl_path=$(wslpath "$1")
        cd "$(realpath "$wsl_path")"
    else
        cd "$(realpath "$1")"
    fi
}

