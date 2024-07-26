# plugins.zsh
#
#   3rd party plugins settings
#


# ==== Environment variables ====

## homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

## w3m
export PATH="$PATH:/usr/lib/w3m"


# ==== Utility aliases ====

## ranger
rag() {
    if [ -z "$RANGER_LEVEL" ]
    then
        ranger
    else
        exit
    fi
}

## Clash
alias setproxy="export https_proxy=http://127.0.0.1:7890;export http_proxy=http://127.0.0.1:7890;export all_proxy=socks5://127.0.0.1:7891"
alias unsetproxy="unset https_proxy;unset http_proxy;unset all_proxy"


# ==== Initialization ====

## zoxide
eval "$(zoxide init zsh)"

## starship
eval "$(starship init zsh)"

## fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source ~/.config/fzf/fzf_config.zsh


