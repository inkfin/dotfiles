# FETCHCONTENT_TRY_FIND_PACKAGE_MODE = OPT_IN, ALWAYS, NEVER
# OPT_IN: FetchContent will only try to find the package if the user explicitly asks for it.
# ALWAYS: FetchContent will always try to find the package.
# NEVER: FetchContent will never try to find the package.

include(FetchContent)

## GoogleTest
FetchContent_Declare(
    googletest
    GIT_REPOSITORY  https://github.com/google/googletest.git
    GIT_TAG         6910c9d9165801d8827d628cb72eb7ea9dd538c5 # release-1.16.0
    SOURCE_DIR      ${CMAKE_SOURCE_DIR}/third_party/googletest
    GIT_PROGRESS TRUE
    FIND_PACKAGE_ARGS NAMES GTest CONFIG REQUIRED
)
FetchContent_MakeAvailable(googletest)

if(DEFINED googletest_SOURCE_DIR AND NOT googletest_SOURCE_DIR STREQUAL "")
    message(STATUS "📌 GoogleTest will be available at ${googletest_SOURCE_DIR}")
else()
    message(STATUS "🖥 Using GoogleTest from system")
endif()

