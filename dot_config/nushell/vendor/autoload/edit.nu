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
    $env.ALL_PROXY = "socks5://127.0.0.1:7890"
    $env.http_proxy = "http://127.0.0.1:7890"
    $env.https_proxy = "http://127.0.0.1:7890"
    $env.all_proxy = "socks5://127.0.0.1:7890"
}

def --env unsetproxy [] {
    hide-env HTTP_PROXY HTTPS_PROXY ALL_PROXY http_proxy https_proxy all_proxy
}

def setgitproxy [] {
    ^git config --global https.proxy "http://127.0.0.1:7890"
    ^git config --global http.proxy  "http://127.0.0.1:7890"
    ^git config --global ssh.proxy   "socks5://127.0.0.1:7890"
}

def unsetgitproxy [] {
    ^git config --global --unset https.proxy
    ^git config --global --unset http.proxy
    ^git config --global --unset ssh.proxy
}

# extract: extract any archive by extension (mirrors omz `extract` plugin)
def extract [file: path] {
    let f = ($file | path expand)
    if not ($f | path exists) {
        print $"extract: file not found: ($f)"
        return
    }
    let name = ($f | path basename | str lowercase)
    match [$name] {
        [$n if ($n =~ '\.tar\.gz$|\.tgz$')]    => { ^tar xzf $f }
        [$n if ($n =~ '\.tar\.bz2$|\.tbz2?$')] => { ^tar xjf $f }
        [$n if ($n =~ '\.tar\.xz$|\.txz$')]    => { ^tar xJf $f }
        [$n if ($n =~ '\.tar\.zst$|\.tzst$')]  => { ^tar --zstd -xf $f }
        [$n if ($n =~ '\.tar$')]                => { ^tar xf $f }
        [$n if ($n =~ '\.gz$')]               => { ^gunzip $f }
        [$n if ($n =~ '\.bz2$')]              => { ^bunzip2 $f }
        [$n if ($n =~ '\.xz$')]               => { ^unxz $f }
        [$n if ($n =~ '\.zst$')]              => { ^unzstd $f }
        [$n if ($n =~ '\.zip$')]              => { ^unzip $f }
        [$n if ($n =~ '\.7z$')]               => { ^7z x $f }
        [$n if ($n =~ '\.rar$')]              => { ^unrar x $f }
        [$n if ($n =~ '\.Z$')]                => { ^uncompress $f }
        _ => { print $"extract: unknown archive type: ($f)" }
    }
}

# vim: ft=nu
