#!/bin/bash

version=$1
if [ -z "$version" ]; then
    echo "Usage: $0 <dawn_version> [<build_mode>]"
    exit 1
fi
mode=${2:-RelWithDebInfo}
binary_dir=${version}/build/${mode}

cmake -S ${version} -B ${binary_dir} -DDAWN_FETCH_DEPENDENCIES=ON -DDAWN_ENABLE_INSTALL=ON -DCMAKE_BUILD_TYPE=${mode} -GNinja

cmake --build ${binary_dir}
