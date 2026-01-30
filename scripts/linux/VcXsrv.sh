#!/usr/bin/env bash

# This is how we use emacs / other gui apps in WSL
#
# First install VcXsrv on Windows <https://github.com/marchaesen/vcxsrv>
# Then run this script in WSL before starting emacs or other gui apps
# to setup X11 forwarding

export DISPLAY=$(ip route | awk '/default/ { print $3 }'):1.0
export LIBGL_ALWAYS_INDIRECT=1
export LIBGL_ALWAYS_SOFTWARE=true

