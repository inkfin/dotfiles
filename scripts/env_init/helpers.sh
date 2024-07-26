#!/bin/bash

# check if has command
function is_command() {
    command -v "$1" >/dev/null 2>&1
}

function get_system_name() {
    local system_name=$(uname -s)

    if [[ "$system_name" == "Linux" ]]; then
        # Parse /etc/os-release
        . /etc/os-release
        local os_name="$NAME"
        system_name="$os_name"
    fi

    echo "$system_name"
}

function install_pkg() {
    local pkg_name=$1
    local system_name=$(get_system_name)

    if [[ "$system_name" =~ Darwin ]]; then
        # For macOS, use Homebrew
        pkg_manager=("brew")
    elif [[ "$system_name" =~ Ubuntu ]]; then
        # For Ubuntu, use apt-get
        pkg_manager=("sudo" "apt-get" "-y")
    else
        pkg_manager=("pac")
    fi

    echo "(${pkg_manager[@]}) Installing $pkg_name..."

    # echo "executing: ${pkg_manager[@]} install $pkg_name"
    ${pkg_manager[@]} install $pkg_name
    if [ $? -eq 0 ]; then
        echo "(${pkg_manager[@]}) $pkg_name installed."
    else
        echo "(${pkg_manager[@]}) Install $pkg_name error. continue..."
    fi
}

function install_if_not_exist() {
    if ! is_command $1; then
        install_pkg $1
    fi
}

function brew_install_pkg() {
    local pkg_name=$1

    echo "(brew) Installing $pkg_name..."

    # echo "executing: brew install $pkg_name"
    brew install $pkg_name
    if [ $? -eq 0 ]; then
        echo "(brew) $pkg_name installed."
    else
        echo "(brew) Install $pkg_name error. continue..."
    fi
}

function brew_install_if_not_exist() {
    if ! is_command $1; then
        brew_install_pkg $1
    fi
}
