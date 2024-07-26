#!/bin/bash

. $HOME/scripts/env_init/helpers.sh

pkg_list=()
brew_pkg_list=(tmux ranger fzf unzip rg fd bat zoxide starship lsd bottom glow)

install_if_not_exist ${pkg_list[@]}

brew_install_if_not_exist ${brew_pkg_list[@]}
