#!/bin/bash

cd "$HOME"

. ~/scripts/env_init/helpers.sh

if ! is_command neovim; then
    echo "==========================================="
    echo "==== installing neovim & prerequisites ===="
    echo "==========================================="
    command_list=(nodejs python3 neovim lazygit)
    for command in ${command_list[*]}; do
        brew_install_if_not_exist $command
    done
fi
