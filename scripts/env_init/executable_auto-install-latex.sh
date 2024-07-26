#!/bin/bash

. $HOME/scripts/env_init/helpers.sh

if ! is_command neovim; then
    echo "==========================================="
    echo "======= installing pandoc & miktex ========"
    echo "==========================================="

    if ! is_command brew; then
        echo "[ERROR]: can't find homebrew in path"
        read -n1 -p "> should we try install brew now? : [y/n]" answer
        case $answer in
        Y | y)
            echo "> running ~/.scripts/env_init/auto-install-homebrew.sh"
            /bin/bash $HOME/scripts/env_init/auto-install-homebrew.sh
            ;;
        N | n)
            echo "ok, good bye"
            exit
            ;;
        *)
            echo "ok, good bye"
            exit
            ;;
        esac
    fi

    # install pandoc for exporting
    brew_install_if_not_exist pandoc

    if [[ $(uname -s) == "Linux" ]]; then
        echo "No package for current system; check <https://miktex.org/howto/install-miktex-unx>"
    else
        # prefer miktex to texlive
        brew_install_if_not_exist miktex
    fi
fi

# IMPORTANT: Remember to open miktex-console to
#     apply update & set auto-install !!!

## Templates
# Eisvogel
#   [https://github.com/Wandmalfarbe/pandoc-latex-template]
#
## Some cool fonts
#
# Chinese
#   - Smiley-Sans
#     [https://github.com/atelier-anchor/smiley-sans/releases/latest]
#
