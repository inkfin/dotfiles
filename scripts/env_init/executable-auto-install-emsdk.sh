#!/usr/bin/env bash
set -euo pipefail

EMSDK_HOME="${EMSDK_HOME:-$HOME/dev/emsdk}"

if [ -z "$EMSDK_HOME" ]; then
    echo "[emsdk] EMSDK_HOME not set, aborting"
    exit 1
fi

mkdir -p "$EMSDK_HOME"

if [ -d "$EMSDK_HOME/.git" ]; then
    exit 0
fi

echo "[emsdk] cloning into $EMSDK_HOME"
git clone https://github.com/emscripten-core/emsdk.git "$EMSDK_HOME"

