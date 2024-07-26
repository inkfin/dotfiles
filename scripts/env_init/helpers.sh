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
    local pkg_names=("$@")
    local install_command="install"
    local system_name=$(get_system_name)

    if [[ "$system_name" =~ Darwin ]]; then
        # For macOS, use Homebrew
        pkg_manager=("brew")
    elif [[ "$system_name" =~ Ubuntu ]]; then
        # For Ubuntu, use apt-get
        pkg_manager=("sudo" "apt-get")
        install_command="install -y"
    elif [[ "$system_name" =~ "openSUSE" ]]; then
        # Tumbleweed && Leap
        pkg_manager=("sudo" "zypper")
        install_command="in -y"
    else
        pkg_manager=("pac")
    fi

    echo "(${pkg_manager[@]}) Installing ${pkg_names[@]}..."

    # echo "executing: ${pkg_manager[@]} install ${pkg_names[@]}"
    ${pkg_manager[@]} $install_command "${pkg_names[@]}"
    if [ $? -eq 0 ]; then
        echo "(${pkg_manager[@]}) ${pkg_names[@]} installed."
    else
        echo "(${pkg_manager[@]}) Install ${pkg_names[@]} error. continue..."
    fi
}

function install_if_not_exist() {
    install_pkg $@
}

function brew_install_pkg() {
    local pkg_names=("$@")

    echo "(brew) Installing ${pkg_names[@]}..."

    # echo "executing: brew install ${pkg_names[@]}"
    brew install ${pkg_names[@]}
    if [ $? -eq 0 ]; then
        echo "(brew) ${pkg_names[@]} installed."
    else
        echo "(brew) Install ${pkg_names[@]} error. continue..."
    fi
}

function brew_install_if_not_exist() {
    brew_install_pkg $@
}
