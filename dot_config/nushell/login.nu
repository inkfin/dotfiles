# login.nu
# Loaded only when nushell starts as a login shell (nu -l)

# Ensure standard paths are available
$env.PATH = ($env.PATH | append [
    "~/.local/bin",
    "~/bin",
    "~/.cargo/bin",
    "~/scoop/shims",
])

# Homebrew on Windows (if installed)
let brew_bin = "~/scoop/apps/homebrew/current/bin"
if ($brew_bin | path expand | path exists) {
    $env.PATH = ($env.PATH | append ($brew_bin | path expand))
}

# bun
let bun_bin = "~/.bun/bin"
if ($bun_bin | path expand | path exists) {
    $env.PATH = ($env.PATH | append ($bun_bin | path expand))
}

# XDG base directories
$env.XDG_CONFIG_HOME = ("~/.config" | path expand)
$env.XDG_DATA_HOME = ("~/.local/share" | path expand)
$env.XDG_CACHE_HOME = ("~/.cache" | path expand)

# Rust / Cargo
$env.CARGO_HOME = ("~/.cargo" | path expand)

# Go
$env.GOPATH = ("~/go" | path expand)

# Editor / Pager
$env.VISUAL = "nvim"
$env.PAGER = "less"
$env.MANPAGER = "nvim +Man!"

# FZF defaults
$env.FZF_DEFAULT_OPTS = "--height 40% --layout reverse --border"

# Less history
$env.LESSHISTFILE = "-"

# vim: ft=nu
