#!/bin/bash

. $HOME/scripts/env_init/helpers.sh

if ! is_command zsh; then
    install_if_not_exist zsh
    sudo chsh -s $(which zsh)
fi
