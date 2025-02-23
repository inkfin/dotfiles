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

$env.EDITOR = "nvim"

$env.config.buffer_editor = "nvim"

# Load the starship prompt
#source ~/.cache/starship/init.nu

# history
$env.config.history = {
  file_format: sqlite
  max_size: 1_000_000
  sync_on_enter: true
  isolation: true
}

$env.config.show_banner = false

alias nu-open = open
alias open = ^open

alias l = lsd
alias ll = lsd -l
alias la = lsd -al
alias pwd = echo $env.PWD
alias v = nvim
alias nvi = neovide
alias ra = yazi
alias lg = lazygit
alias cz = chezmoi

alias ee = exit
