# ________________________
# ___  ____/__  /__  ____/
# __  /_   __  /__  /_    
# _  __/   _  /__  __/    
# /_/      /____/_/       
#                         

# fzf user config. This file is loaded only in interactive zsh shells.

# fd searches paths; rg searches file contents. Use fd for fzf's file list.
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# Options to fzf command
export FZF_COMPLETION_OPTS='--border --info=inline'


# General fzf completion options. Type **<TAB> after a path to use them.
export FZF_DEFAULT_OPTS='--no-height --no-reverse'


# Ctrl-T: fzf's standard file picker, including hidden files.
# bat provides the preview (https://github.com/sharkdp/bat).
export FZF_CTRL_T_OPTS="
  --reverse
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'
  --header 'Press CTRL-/ to toggle preview'
  --select-1 --exit-0"


# Ctrl-R: fzf's history picker. Ctrl-/ toggles the preview.
export FZF_CTRL_R_OPTS="
  --reverse
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --color header:italic
  --header 'Press CTRL-/ to toggle preview'"

# Ctrl-F: file picker excluding hidden files. The selected path is inserted
# at the current cursor position instead of executing anything.
_fzf_file_no_hidden() {
  local result
  result="$(fd --type f --follow --exclude .git 2>/dev/null | fzf \
    --preview 'bat -n --color=always {}' \
    --preview-window=right:60%:wrap)" || return
  LBUFFER+="$result"
  zle redisplay
}
if command -v fd >/dev/null 2>&1; then
  zle -N _fzf_file_no_hidden
  bindkey '^F' _fzf_file_no_hidden
fi


# Alt-C: directory picker. tree is only used for the preview.
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head --200'
  --reverse
  --select-1 --exit-0"


# fzf-tmux settings
export FZF_TMUX_OPTS='-p80%,60%'

if command -v fd >/dev/null 2>&1; then
  # Use fd instead of find for fzf path completion. The first argument is the
  # directory where completion starts. Without fd, fzf keeps its own default.
  _fzf_compgen_path() {
    fd --type f --hidden --follow --exclude ".git" . "$1"
  }

  _fzf_compgen_dir() {
    fd --type d --hidden --follow --exclude ".git" . "$1"
  }
fi

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
