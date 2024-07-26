# dev.zsh
#
#   developement related commands
#


# ==== Environment variables ====
#
#   *hint:
#     $PATH:                executable paths
#   (*Linux)
#     $LD_LIBRARY_PATH:     dynamic library paths
#   (*MacOS)
#     $DYLD_LIBRARY_PATH:   dynamic library paths
#

## dylib
export DYLD_LIBRARY_PATH="$HOME/.local/lib:/usr/local/lib:$DYLD_LIBRARY_PATH"
export LD_LIBRARY_PATH="$HOME/.local/lib:/usr/local/lib:$LD_LIBRARY_PATH"

## vcpkg
export VCPKG_HOME="$HOME/vcpkg"
export PATH="$VCPKG_HOME:$PATH"

## Rustup
export PATH="/home/linuxbrew/.linuxbrew/opt/rustup/bin:$PATH"

## Cargo
export CARGO_HOME="$HOME/.cargo/"
export PATH="$CARGO_HOME/bin:$PATH"

## cuda
#   set PATH & LD_LIBRARY_PATH in local.zsh
CUDA124_HOME="/usr/local/cuda-12.4"

## nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# ==== Utility aliases ====

## CMake
alias cmc="cmake -S . -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B"
alias cmcv="cmake -S . -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_TOOLCHAIN_FILE=$VCPKG_HOME/vcpkg/scripts/buildsystems/vcpkg.cmake -B"
alias cmb="cmake --build "


# ==== Initialization ====


