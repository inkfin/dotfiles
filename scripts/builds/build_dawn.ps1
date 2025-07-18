if ($args.Count -lt 1) {
    Write-Host "Usage: .\build_dawn.ps1 <source_dir> [profile]"
    exit 1
}
$profile = if ($args.Count -ge 2) { $args[1] } else { "RelWithDebInfo" }
$out_dir = "$($args[0])/build/$($profile)"

# $env:CXXFLAGS = "$env:CXXFLAGS -DNOMINMAX -D_USE_MATH_DEFINES"

# Don't use Ninja Multi-Config when install
cmake -S $args[0] -B "$out_dir" -G "Ninja" `
    -DCMAKE_BUILD_TYPE="$profile" `
    -DCMAKE_CXX_FLAGS="-DNOMINMAX -D_USE_MATH_DEFINES" `
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON `
    -DDAWN_FETCH_DEPENDENCIES=ON `
    -DDAWN_ENABLE_INSTALL=ON

cmake --build "$out_dir"
