# config.nu
#
# Installed by:
# version = "0.102.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
#
# You can remove these comments if you want or leave
# them for future reference.

source ($nu.default-config-dir | path join "utils.nu")

$env.EDITOR = "nvim"

$env.config.buffer_editor = "nvim"
$env.config.edit_mode = 'emacs'

# history
$env.config.history = {
  file_format: sqlite
  max_size: 1_000_000
  sync_on_enter: true
  isolation: true
}

$env.config.show_banner = false

# paths
$env.PATH = $env.PATH | append (safe_expand_path "~/bin")
$env.PATH = $env.PATH | append (safe_expand_path "~/.local/bin")

#=========
# Aliases
#=========
alias l = lsd
alias ll = lsd -l
alias la = lsd -al
alias lt = lsd --tree
alias pwd = echo $env.PWD
alias ra = yazi
def --env rag [...args] {
	let tmp = (mktemp -t "yazi-cwd.XXXXXX")
	yazi ...$args --cwd-file $tmp
	let cwd = (open $tmp)
	if $cwd != "" and $cwd != $env.PWD {
		cd $cwd
	}
	rm -fp $tmp
}

# chezmoi
alias cz = chezmoi
$env.chezmoi-dir = "~/.local/share/chezmoi" | path expand

alias ee = exit

# load completions
const NU_LIB_DIRS = [
  ($nu.data-dir | path join "completions"),
]

# initialization
mkdir ($nu.data-dir | path join "vendor/autoload")

starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
zoxide init nushell | save -f ($nu.data-dir | path join "vendor/autoload/zoxide.nu")

