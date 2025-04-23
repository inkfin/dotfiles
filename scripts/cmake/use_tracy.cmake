# FETCHCONTENT_TRY_FIND_PACKAGE_MODE = OPT_IN, ALWAYS, NEVER
# OPT_IN: FetchContent will only try to find the package if the user explicitly asks for it.
# ALWAYS: FetchContent will always try to find the package.
# NEVER: FetchContent will never try to find the package.

include(FetchContent)

option(TRACY_ENABLE "Enable Tracy profiler" OFF)
option(TRACY_ON_DEMAND "Enable Tracy on-demand profiler" OFF)

## Tracy
FetchContent_Declare(
    tracy
    GIT_REPOSITORY  https://github.com/wolfpld/tracy.git
    GIT_TAG         v0.11.1
    GIT_SHALLOW     TRUE
    GIT_PROGRESS    TRUE
    SOURCE_DIR      ${CMAKE_SOURCE_DIR}/third_party/tracy
)
FetchContent_MakeAvailable(tracy)

if(DEFINED tracy_SOURCE_DIR AND NOT tracy_SOURCE_DIR STREQUAL "")
    message(STATUS "📌 Tracy will be available at ${tracy_SOURCE_DIR}")
else()
    message(STATUS "🖥 Using Tracy from system")
endif()

