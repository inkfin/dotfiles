# -*- zsh -*-
# vi: ft=zsh

# ======================================
#  local.zsh
# ======================================
#   files that stores local changes, this file won't be synced to chezmoi
# ======================================

# Machine-local integrations such as Docker Desktop and Conda belong here.
# This create_ file is only used to initialize ~/.zshrc.d/local.zsh once.
if [[ -d "$HOME/.docker/completions" ]]; then
    fpath=("$HOME/.docker/completions" $fpath)
fi


