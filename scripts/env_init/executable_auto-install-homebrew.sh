#!/bin/bash

. ~/scripts/env_init/helpers.sh

# linuxbrew prerequisites
if [[ $(uname -s) == "Linux" ]]; then
    local system_name=$(get_system_name)
    if [[ "$system_name" == "Ubuntu" ]]; then
        sudo apt-get install build-essential procps curl file git
    else
        echo "($system_name) needs install homebrew requirements: https://docs.brew.sh/Homebrew-on-Linux#requirements"
    fi
fi

# install homebrew
if ! is_command brew; then
    echo "Installing linuxbrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# update index
brew update

# install requirements
brew install hello

if [ -f "$HOME/.Brewfile" ]; then
    echo "Updating homebrew bundle"
    brew bundle --global
fi
