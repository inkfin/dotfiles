# config.nu

source ($nu.default-config-dir | path join "utils.nu")

# ---------------------------------------------------------------------------
# Version helper: returns true when running nushell >= (major, minor, patch).
# Uses an integer encoding since nushell can't compare lists with '>'.
# Usage:  if (nu_version_at 0 106 0) { ... }
# ---------------------------------------------------------------------------
def nu_version_at [major: int, minor: int, patch?: int] {
    let patch = ($patch | default 0)
    let v = (version)
    let cur = ($v.major * 1_000_000 + $v.minor * 1_000 + $v.patch)
    let tgt = ($major * 1_000_000 + $minor * 1_000 + $patch)
    $cur >= $tgt
}

$env.EDITOR = "nvim"
$env.SHELL = "nu"
$env.config.edit_mode = "vi"
$env.config.buffer_editor = "nvim"
# error_style: "short" added in 0.106; older versions only accept "fancy"/"plain"
$env.config.error_style = (if (nu_version_at 0 106 0) { "short" } else { "plain" })
$env.config.rm.always_trash = true

$env.config.show_banner = false

$env.config.history = {
    file_format: "sqlite"
    max_size: 1_000_000
    sync_on_enter: true
    isolation: true
}

$env.config.cursor_shape = {
    emacs: "block"
    vi_insert: "line"
    vi_normal: "block"
}

# UI / Display
$env.config.completions.algorithm = "fuzzy"
$env.config.table.header_on_separator = true
$env.config.render_right_prompt_on_last_line = true
# Kitty keyboard protocol: skip inside tmux (tmux speaks extended-keys/CSI u, not kitty).
# Enabling kitty here under tmux would make Shift+Enter etc. get dropped/mistranslated.
if ("TMUX" not-in $env) {
    $env.config.use_kitty_protocol = true
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
alias rm! = rm -p
$env.chezmoi-dir = ("~/.local/share/chezmoi" | path expand)

# Abbreviations (expand on space, store full command in history).
# Added in 0.106; on older versions fall back to aliases so config still loads.
if (nu_version_at 0 106 0) {
    $env.config.abbreviations = {
        gst: "git status"
        lg: "lazygit"
        lzd: "lazydocker"
        zj: "zellij"
        cmc: "cmake -S . -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B"
        cmcp: "cmake --preset"
        cmb: "cmake --build"
    }
} else {
    alias gst = git status
    alias lg = lazygit
    alias lzd = lazydocker
    alias zj = zellij
    alias cmc = cmake -S . -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B
    alias cmcp = cmake --preset
    alias cmb = cmake --build
}

# Keybindings: Alt+. inserts last token of previous command (bash-style)
#              Alt+Backspace deletes the previous word (emacs-style)
$env.config.keybindings ++= [
    {
        name: insert_last_token
        modifier: alt
        keycode: char_.
        mode: [emacs vi_normal vi_insert]
        event: {
            send: executehostcommand
            cmd: "commandline edit --insert (history | last | get command | split row (char space) | last)"
        }
    }
    {
        name: delete_word_back
        modifier: alt
        keycode: backspace
        mode: [emacs vi_insert]
        event: { edit: BackspaceWord }
    }
]

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
