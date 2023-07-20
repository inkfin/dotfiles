# ________________________
# ___  ____/__  /__  ____/
# __  /_   __  /__  /_    
# _  __/   _  /__  __/    
# /_/      /____/_/       
#                         

# fzf user config

# Options to fzf command
export FZF_COMPLETION_OPTS='--border --info=inline'


# Dir completion, type **<TAB> to trigger (fullscreen)
export FZF_DEFAULT_OPTS='--no-height --no-reverse'


# Dir completion
# Preview file content using bat (https://github.com/sharkdp/bat)
export FZF_CTRL_T_OPTS="
  --reverse
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'
  --header 'Press CTRL-/ to toggle preview'
  --select-1 --exit-0"


# Search history
# CTRL-/ to toggle small preview window to see the full command
export FZF_CTRL_R_OPTS="
  --reverse
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --color header:italic
  --header 'Press CTRL-/ to toggle preview'"


# Cd dir completion
# Print tree structure in the preview window
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head --200'
  --reverse
  --select-1 --exit-0"


# fzf-tmux settings
export FZF_TMUX_OPTS='-p80%,60%'

# Use fd (https://github.com/sharkdp/fd) instead of the default find
# command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --type f --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'tree -C {} | head -200'   "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview 'bat -n --color=always {}' "$@" ;;
  esac
}

# tomasr/molokai
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS' --color=bg+:#293739,bg:#1B1D1E,border:#808080,spinner:#E6DB74,hl:#7E8E91,fg:#F8F8F2,header:#7E8E91,info:#A6E22E,pointer:#A6E22E,marker:#F92672,fg+:#F8F8F2,prompt:#F92672,hl+:#F92672'
