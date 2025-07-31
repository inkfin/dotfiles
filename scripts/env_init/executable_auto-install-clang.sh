#!/bin/bash

# Function to install Clang on macOS
install_clang_macos() {
    echo "Installing Clang on macOS..."
    # Make sure Homebrew is installed
    if ! command -v brew &>/dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    # Install Clang via Homebrew
    brew install llvm
    echo "Clang installed successfully on macOS."
}

# Function to install Clang on Ubuntu
install_clang_ubuntu() {
    echo "Installing Clang on Ubuntu..."
    sudo apt update
    sudo apt install -y clang
    echo "Clang installed successfully on Ubuntu."
}

# Function to install Clang on Fedora
install_clang_fedora() {
    echo "Installing Clang on Fedora..."
    sudo dnf install -y llvm
    sudo dnf install -y clang
    sudo dnf install -y clang-tools-extra # install clangd
    echo "Clang installed successfully on Fedora."
}

# Function to install Clang on TencentOS
install_clang_tencentos() {
    echo "Installing Clang on TencentOS..."
    sudo dnf install -y llvm
    sudo dnf install -y clang
    sudo dnf install -y clang-tools-extra # install clangd
    echo "Clang installed successfully on TencentOS."
}

# Function to detect the OS using regex
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Detected macOS"
        install_clang_macos
    elif [[ -f /etc/os-release ]]; then
        # Extract the distribution name
        DISTRO_NAME=$(grep '^NAME=' /etc/os-release | cut -d'=' -f2 | tr -d '"')

        # Use regular expression to detect the Linux distribution (partial match)
        if [[ "$DISTRO_NAME" =~ Ubuntu ]]; then
            echo "Detected Ubuntu (or Ubuntu-based)"
            install_clang_ubuntu
        elif [[ "$DISTRO_NAME" =~ Fedora ]]; then
            echo "Detected Fedora (or Fedora-based)"
            install_clang_fedora
        elif [[ "$DISTRO_NAME" =~ TencentOS ]]; then
            echo "Detected TencentOS (or TencentOS-based)"
            install_clang_tencentos
        else
            echo "Unsupported Linux distribution: $DISTRO_NAME"
            exit 1
        fi
    else
        echo "Unsupported operating system: $OSTYPE"
        exit 1
    fi
}

# Start the installation process
detect_os
