# config.nu

source ($nu.default-config-dir | path join "utils.nu")

$env.EDITOR = "nvim"
$env.config.edit_mode = "emacs"

$env.config.show_banner = false

$env.config.history = {
    file_format: "sqlite"
    max_size: 1_000_000
    sync_on_enter: true
    isolation: true
}

$env.config.cursor_shape = {
    emacs: "line"
    vi_insert: "line"
    vi_normal: "block"
}

use std/util "path add"
path add "~/.local/bin"
path add "~/bin"

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------
alias l = lsd
alias ll = lsd -l
alias la = lsd -al
alias lt = lsd --tree
alias ee = exit

alias cz = chezmoi
$env.chezmoi-dir = ("~/.local/share/chezmoi" | path expand)

def --env y [...args] {
    let tmp = (mktemp -t "yazi-cwd.XXXXXX")
    ^yazi ...$args --cwd-file $tmp
    let cwd = (open $tmp)
    if $cwd != "" and $cwd != $env.PWD {
        cd $cwd
    }
    rm -fp $tmp
}

# ---------------------------------------------------------------------------
# Completions
# ---------------------------------------------------------------------------
const NU_LIB_DIRS = [
    ($nu.data-dir | path join "completions"),
]

mkdir ($nu.data-dir | path join "completions")

# ---------------------------------------------------------------------------
# Prompt: starship (always refresh init, fast enough for startup)
# ---------------------------------------------------------------------------
mkdir ($nu.data-dir | path join "vendor" "autoload")
^starship init nu | save --force ($nu.data-dir | path join "vendor" "autoload" "starship.nu")
source ($nu.data-dir | path join "vendor" "autoload" "starship.nu")

# ---------------------------------------------------------------------------
# zoxide
# ---------------------------------------------------------------------------
^zoxide init nushell | save --force ($nu.data-dir | path join "vendor" "autoload" "zoxide.nu")
source ($nu.data-dir | path join "vendor" "autoload" "zoxide.nu")
