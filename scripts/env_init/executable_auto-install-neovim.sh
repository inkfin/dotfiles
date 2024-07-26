#!/bin/bash

cd "$HOME"

. $HOME/scripts/env_init/helpers.sh

if ! is_command neovim; then
    echo "==========================================="
    echo "==== installing neovim & prerequisites ===="
    echo "==========================================="
    command_list=(nodejs python3 neovim lazygit)
    brew_install_if_not_exist ${command_list[@]}
fi
