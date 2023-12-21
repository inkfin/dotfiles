#!/bin/bash

# Because Git submodule commands cannot operate without a work tree, they must
# be run from within $HOME (assuming this is the root of your dotfiles)
cd "$HOME"

# check for installed flag
if [ -f $HOME/.init_flag ]; then
	echo "Found init flag (~/.init_flag), skipping bootstrap script."
	exit
else
	touch $HOME/.init_flag
	echo "Running bootstrap script..."
fi

system_type=$(uname -s)

pkg_manager=("pac")

# check if has command
is_command() {
	command -v "$1" >/dev/null 2>&1
}

install_command() {
	echo "Installing $1..."
	${pkg_manager[@]} install -y $2
	if [ $? -eq 0 ]; then
		echo "$2 installed."
	else
		echo "Install $2 error."
	fi
}

install_if_not_exist() {
	if ! is_command $1; then
		install_command $1
	fi
}

# define command list
command_list=(zsh tmux ranger fzf rg fd bat zoxide lsd)

# MacOS
if [ ${system_type} = "Darwin" ]; then
	pkg_manager=("brew")

	# install homebrew
	if ! is_command brew; then
		echo "Installing homebrew"
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi

	$pkg_manager update

	if [ -f "$HOME/.Brewfile" ]; then
		echo "Updating homebrew bundle"
		brew bundle --global
	fi

	# install basic command in list
	for command in ${command_list[*]}; do
		install_if_not_exist $command
	done

	# fzf init
	/opt/homebrew/opt/fzf/install

	# Vim init
	install_if_not_exist neovim
	# if is_command nvim; then
	# 	echo "Bootstraping NeoVim"
	# 	nvim '+PlugUpdate' '+PlugClean!' '+PlugUpdate' '+CocInstall' '+qall'
	# fi

fi

# Linux
if [ ${system_type} = "Linux" ]; then
	pkg_manager=("sudo" "apt-get")

	${pkg_manager[@]} update

	# install basic command in list
	for command in ${command_list[*]}; do
		echo $command
		install_if_not_exist $command
	done

	# set zsh as default shell
	sudo chsh -s $(which zsh)

	# Vim init
	install_if_not_exist neovim
	# if is_command nvim; then
	# 	echo "Bootstraping NeoVim"
	# 	nvim '+PlugUpdate' '+PlugClean!' '+PlugUpdate' '+CocInstall' '+qall'
	# fi

fi
