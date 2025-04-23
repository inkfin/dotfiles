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
    GIT_SHALLOW     TRUE
    GIT_PROGRESS    TRUE
    SOURCE_DIR      ${CMAKE_SOURCE_DIR}/third_party/googletest
    FIND_PACKAGE_ARGS NAMES GTest CONFIG REQUIRED
)
FetchContent_MakeAvailable(googletest)

if(DEFINED googletest_SOURCE_DIR AND NOT googletest_SOURCE_DIR STREQUAL "")
    message(STATUS "📌 GoogleTest will be available at ${googletest_SOURCE_DIR}")
else()
    message(STATUS "🖥 Using GoogleTest from system")
endif()


## Configuration

enable_testing()

if(WIN32)
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
endif()

# add_library(${BINARY_NAME}_lib STATIC ${SOURCE_FILES}) # Apps source files

# file(GLOB_RECURSE TEST_FILES CONFIGURE_DEPENDS
#     LIST_DIRECTORIES false
#     test/*.cpp test/*.h
# )

# add_executable(gtest ${TEST_FILES})

# target_link_libraries(gtest PRIVATE ${BINARY_NAME}_lib
#     GTest::gtest GTest::gtest_main GTest::gmock GTest::gmock_main)

# include(GoogleTest)
# gtest_discover_tests(gtest)
