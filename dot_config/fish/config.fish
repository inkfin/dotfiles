# _____ _     _                       __ _
#|  ___(_)___| |__    ___ ___  _ __  / _(_) __ _
#| |_  | / __| '_ \  / __/ _ \| '_ \| |_| |/ _` |
#|  _| | \__ \ | | || (_| (_) | | | |  _| | (_| |
#|_|   |_|___/_| |_(_)___\___/|_| |_|_| |_|\__, |
#                                          |___/

# There are three kinds of variables in fish: universal, global and local variables. 
# Universal variables are shared between all fish sessions a user is running on one computer. 
# Global variables are specific to the current fish session, but are not associated with any 
#   specific block scope, and will never be erased unless the user explicitly requests it using set -e. 
# Local variables are specific to the current fish session, and associated with a specific block of 
#   commands, and is automatically erased when a specific block goes out of scope. 
# A block of commands is a series of commands that begins with one of the commands for, while , if, function, 
#   begin or switch, and ends with the command end. 
# The user can specify that a variable should have either global or local scope using the -g/--global or -l/--local switches.

# Variables can be explicitly set to be universal with the -U or --universal switch, 
# global with the -g or --global switch, or local with the -l or --local switch.




# =========================================================
# == At Start
# =========================================================

set fish_greeting "Keep Calm && Carry On"
set -g -x RANGER_LOAD_DEFAULT_RC FALSE
#fortune



# =========================================================
# == Environment Variables
# =========================================================


fish_add_path /usr/local/sbin


# homebrew
fish_add_path -m /opt/homebrew/bin
set -gx CPPFLAGS "-I/opt/homebrew/include " $CPPFLAGS
set -gx LDFLAGS "-L/opt/homebrew/lib -Wl,-rpath,/opt/homebrew/lib " $LDFLAGS
set -gx HOMEBREW_NO_AUTO_UPDATE 1

# homebrew acceleration
set -x HOMEBREW_BOTTLE_DOMAIN https://mirrors.ustc.edu.cn/homebrew-bottles


# CMake
set -gx CMAKE_INCLUDE_PATH "/opt/homebrew/include"
set -gx CMAKE_LIBRARY_PATH "/opt/homebrew/lib"

# Cargo
fish_add_path -m /Users/inkfin/.cargo/bin


# -------------- LLVM -----------------
# ------- llvm__arm64__version --------
set -g fish_user_paths "/opt/homebrew/opt/llvm/bin" $fish_user_paths

# To use the bundled libc++ please add the following LDFLAGS:
set -gx LDFLAGS "-L/opt/homebrew/opt/llvm/lib/c++ -Wl,-rpath,/opt/homebrew/opt/llvm/lib/c++ -L/opt/homebrew/opt/llvm/lib" $LDFLAGS

# For compilers to find llvm you may need to set:
set -gx CPPFLAGS "-I/opt/homebrew/opt/llvm/include" $CPPFLAGS

#-------- llvm__intel__version --------
#set -g fish_user_paths "/usr/local/opt/llvm/lib" $fish_user_paths
#set -gx LDFLAGS "-L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib" $LDFLAGS
#set -gx CPPFLAGS "-I/usr/local/opt/llvm/include" $CPPFLAGS
#======================================


# the fuck
thefuck --alias | source
set -x THEFUCK_OVERRIDDEN_ALIASES 'gsed,git'


# autojump
[ -f /opt/homebrew/share/autojump/autojump.fish ]; and source /opt/homebrew/share/autojump/autojump.fish


# anaconda3


# JAVA
set -x JAVA_8_HOME ""
set -x JAVA_11_HOME "/opt/homebrew/Cellar/openjdk@11/11.0.16.1_1/libexec/openjdk.jdk/Contents/Home"

set -x JAVA_HOME $JAVA_11_HOME
set -x CLASSPATH "." "$JAVA_HOME/lib/dt.jar" "$JAVA_HOME/lib/tools.jar"
set -x M2_HOME "/Library/Java/apache-maven-3.8.5" $M2_HOME
set -x PATH "$JAVA_HOME/bin" $PATH
set -x PATH "$M2_HOME/bin" $PATH


# OpenCV


# PCL
set -x PCL_PREFIX "/opt/homebrew/Cellar/pcl/1.12.0_1"


# Ruby
fish_add_path /opt/homebrew/opt/ruby/bin
fish_add_path /opt/homebrew/lib/ruby/gems/3.1.0/bin  # gem bin path
set -x LDFLAGS "-L/opt/homebrew/opt/ruby/lib" $LDFLAGS
set -x CPPFLAGS "-I/opt/homebrew/opt/ruby/include" $CPPFLAGS


# gnutls
set -x GUILE_TLS_CERTIFICATE_DIRECTORY /usr/local/etc/gnutls/


# guile
set -x GUILE_LOAD_PATH "/usr/local/share/guile/site/3.0" $GUILE_LOAD_PATH
set -x GUILE_LOAD_COMPILED_PATH "/usr/local/lib/guile/3.0/site-ccache" $GUILE_LOAD_COMPILED_PATH
set -x GUILE_SYSTEM_EXTENSIONS_PATH "/usr/local/lib/guile/3.0/extensions" $GUILE_SYSTEM_EXTENSIONS_PATH


# translate-shell
set -x HOME_LANG "zh-CN"
set -x TARGET_LANG "zh-CN"


# Redis
# To restart redis after an upgrade:
alias restartredis 'brew services restart redis'
# Or, if you don't want/need a background service you can just run:
alias stopredis '/opt/homebrew/opt/redis/bin/redis-server /opt/homebrew/etc/redis.conf'


# =========================================================
# == Alias
# =========================================================

# ---------- M1 Homebrew Versions ---------------
alias abrew '/opt/homebrew/bin/brew' # ARM Homebrew
alias ibrew 'arch -x86_64 /usr/local/bin/brew' # X86 Homebrew

alias vim nvim
alias v nvim
alias ra ranger
alias ee exit
alias cd.. "cd .."

alias matrix "cmatrix -sna"

alias vimrc "vim ~/.local/share/chezmoi/dot_config/nvim/executable_init.vim"
alias vimfish "vim ~/.local/share/chezmoi/dot_config/fish/config.fish"
alias vimzsh "vim ~/.local/share/chezmoi/dot_zshrc_darwin"
alias sourcefish "source ~/.config/fish/config.fish"

# git
alias gst "git status"
alias gcl "git clone"
alias gad "git add"

# SQL
# alias sqlstart "pg_ctl -D /usr/local/var/postgres start"
# alias sqlstop "pg_ctl -D /usr/local/var/postgres stop"
alias sqlserver "/opt/homebrew/opt/postgresql/bin/postgres -D /opt/homebrew/var/postgres"
alias sqlstart  "pg_ctl -D /opt/homebrew/var/postgres start"
alias sqlstop   "pg_ctl -D /opt/homebrew/var/postgres stop"

set -x PATH "/usr/local/mysql-8.0.27-macos11-arm64/bin" $PATH

# Proxy
alias sethttpproxy "export http_proxy=http://127.0.0.1:1087"
alias unsethttpproxy "unset http_proxy"
alias sethttpsproxy "export https_proxy=http://127.0.0.1:1087"
alias unsethttpsproxy "unset https_proxy"
alias setallproxy "export ALL_PROXY=socks5://127.0.0.1:1080"
alias unsetallproxy "unset ALL_PROXY=socks5://127.0.0.1:1080"


# swtichhosts
alias flushDNS "sudo -S killall -HUP mDNSResponder"


# =========================================================
# == Mac Settings
# =========================================================

# Trun off mouse acceleration
alias MACAccelerationOFF "defaults write -g com.apple.mouse.scaling -1"

# Find SecureInput PID
alias MACSecureInput "ioreg -l -d 1 -w 0 | grep SecureInput"


test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

set -gx EDITOR /opt/homebrew/bin/nvim


# ----------- Applications ---------------
# Finder
alias Finder "open /System/Library/CoreServices/Finder.app"
alias fi-do "Finder ~/Documents"
alias fi-xue "Finder ~/Documents/学习资料"
alias fi-tex "Finder ~/Documents/Texts"
alias fi-game "Finder ~/Documents/Game\ Design"

# Typora
alias Typora "open -a Typora.app"
alias ty-do "Typora ~/Documents"
alias ty-game "Typora ~/Documents/Game\ Design/"
alias ty-tex "Typora ~/Documents/Texts"
alias ty-not "Typora ~/Documents/Study\ Notes"

# Safari
alias Safari "open -a Safari.app"

# Vim
alias toeflnotes "vim /Users/inkfin/Documents/学习资料/English\ Learning/TOEFL/Tofel练习/useful_notes.md"

