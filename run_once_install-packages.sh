#!/bin/sh

# Because Git submodule commands cannot operate without a work tree, they must
# be run from within $HOME (assuming this is the root of your dotfiles)
cd "$HOME"

system_type=$(uname -s)

# check if has command
is_command() {
    command -v "$1" > /dev/null 2>&1
}

install_command() {
    echo "Installing $2..."
    $1 install $2
    if [ $? -eq 0 ]; then
        echo "$2 installed."
    else
        echo "Install $2 error."
    fi
}


# MacOS
if [ ${system_type} = "Darwin" ]; then
    # install homebrew
    if ! is_command brew; then
        echo "Installing homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    if [ -f "$HOME/.Brewfile" ]; then
        echo "Updating homebrew bundle"
        brew bundle --global
    fi

    # zsh
    if ! is_command zsh; then
        install_command brew zsh
    fi

    # tmux
    if ! is_command zsh; then
        install_command brew zsh
    fi

    # Utilities
    if ! is_command ranger; then
        install_command brew ranger
    fi
    # Vim init
    if ! is_command nvim; then
        install_command brew neovim
    fi
    if is_command nvim; then
        echo "Bootstraping NeoVim"
        nvim '+PlugUpdate' '+PlugClean!' '+PlugUpdate' '+CocInstall' '+qall'
    fi

fi


# Linux
if [ ${system_type} = "Linux" ]; then
    installer="sudo apt-get"

    sudo apt-get update

    # zsh
    if ! is_command zsh; then
        install_command ${installer} zsh
    fi

    if ! is_command tmux; then
        echo "Installing tmux..."
        install_command ${installer} tmux
    fi

    # Utilities
    if ! is_command ranger; then
        install_command ${installer} ranger
    fi
    # Vim init
    if ! is_command nvim; then
        install_command ${installer} neovim
    fi
    if is_command nvim; then
        echo "Bootstraping NeoVim"
        nvim '+PlugUpdate' '+PlugClean!' '+PlugUpdate' '+CocInstall' '+qall'
    fi

fi
