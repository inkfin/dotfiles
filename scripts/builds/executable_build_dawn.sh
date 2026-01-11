#!/usr/bin/env bash

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

version=$1
if [ -z "$version" ]; then
    echo "Usage: $0 <dawn_version> [<build_mode>]"
    exit 1
fi
mode=${2:-RelWithDebInfo}
binary_dir=${ROOT}/builds/${version}/${mode}

cmake \
    -S ${version} \
    -B ${binary_dir} \
    -DDAWN_FETCH_DEPENDENCIES=ON \
    -DDAWN_ENABLE_INSTALL=ON \
    -DCMAKE_BUILD_TYPE=${mode} \
    -GNinja -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache

cmake --build ${binary_dir} --parallel
