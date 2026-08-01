# neovim
alias v = nvim
alias nvi = neovide

alias vcn = nvim --cmd 'let g:rime=v:true'
alias nvs = nvim --listen localhost:6789 --cmd "let safequit=v:true"
alias nvc = nvim --server localhost:6789 --remote-ui

# yazi (cwd-aware wrapper defined in config.nu)
alias ra = y

# edit configs with $EDITOR
def nvimrc [] {
    ^$env.EDITOR ($nu.home-dir | path join ".local" "share" "chezmoi" "dot_config" "nvim.lazyvim" "init.lua")
}

def nurc [] {
    ^$env.EDITOR ($nu.home-dir | path join ".local" "share" "chezmoi" "dot_config" "nushell" "config.nu")
}

def wezrc [] {
    ^$env.EDITOR ($nu.home-dir | path join ".local" "share" "chezmoi" "dot_config" "wezterm" "wezterm.lua")
}

def virc [] {
    ^$env.EDITOR ($nu.home-dir | path join ".local" "share" "chezmoi" "dot_vim" "vimrc")
}

# reload nushell config
def sourcenu [] {
    source-env $nu.config-path
}

# restart nushell
def restartnu [] {
    exec nu
}

# tmux
alias tl = tmux list-sessions
alias ta = tmux attach -t
alias tad = tmux attach -d -t
alias ts = tmux new-session -s
alias tkss = tmux kill-session -t
alias tksv = tmux kill-server

# proxy
def --env setproxy [] {
    $env.HTTP_PROXY = "http://127.0.0.1:7890"
    $env.HTTPS_PROXY = "http://127.0.0.1:7890"
}

def --env unsetproxy [] {
    hide-env HTTP_PROXY
    hide-env HTTPS_PROXY
}

# vim: ft=nu
