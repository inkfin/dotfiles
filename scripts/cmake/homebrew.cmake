# Use Homebrew packages

set(HOMEBREW_PREFIX "$ENV{HOMEBREW_PREFIX}" CACHE PATH "Path to Homebrew installation")
if(NOT HOMEBREW_PREFIX)
    set(HOMEBREW_PREFIX "/opt/homebrew" CACHE PATH "Path to Homebrew installation" FORCE)
endif()

# Specify the compilers
set(CMAKE_C_COMPILER "${HOMEBREW_PREFIX}/bin/clang")
set(CMAKE_CXX_COMPILER "${HOMEBREW_PREFIX}/bin/clang++")

set(CMAKE_PREFIX_PATH
    "${HOMEBREW_PREFIX}"
    # These libraries are keg-only and not loaded into
    # the root prefix by default (to avoid clashes).
    "${HOMEBREW_PREFIX}/opt/lapack"
    "${HOMEBREW_PREFIX}/opt/openblas"
    "${HOMEBREW_PREFIX}/opt/gcc/lib/gcc/11"
)

list(TRANSFORM CMAKE_PREFIX_PATH APPEND "/include"
     OUTPUT_VARIABLE CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES)
set(CMAKE_C_STANDARD_INCLUDE_DIRECTORIES "${CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES}")

# # Don't search the default paths
# set(CMAKE_FIND_FRAMEWORK NEVER)
# set(CMAKE_FIND_APPBUNDLE NEVER)

# set(CMAKE_FIND_USE_CMAKE_SYSTEM_PATH FALSE)
# set(CMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH FALSE)

