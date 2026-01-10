#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$VCPKG_ROOT"

if [ -d "$VCPKG_ROOT/.git" ]; then
    exit 0
fi

echo "[vcpkg] cloning into $VCPKG_ROOT"
git clone https://github.com/microsoft/vcpkg.git "$VCPKG_ROOT"

