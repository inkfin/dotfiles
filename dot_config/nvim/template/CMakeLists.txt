cmake_minimum_required(VERSION 3.29)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON) # generate compile_commands.json for clangd
set(CMAKE_CXX_EXTENSIONS OFF)

#===== VCPKG ===========================

# if (NOT CMAKE_TOOLCHAIN_FILE)
#     set(CMAKE_TOOLCHAIN_FILE "vcpkg/scripts/buildsystems/vcpkg.cmake" CACHE FORCE)
# endif()


#===== Project Build Options =============

project(HelloWorld LANGUAGES CXX VERSION 0.1)

if (PROJECT_BINARY_DIR STREQUAL PROJECT_SOURCE_DIR)
    message(SEND_ERROR "The binary directory of CMake cannot be the same as source directory!")
endif()

if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

if (WIN32)
    # disable min/max macros to avoid conflicts with std::min/max
    add_definitions(-DNOMINMAX -D_USE_MATH_DEFINES)
endif()

if (NOT MSVC)
    find_program(CCACHE_PROGRAM ccache)
    if (CCACHE_PROGRAM)
        message(STATUS "Found CCache: ${CCACHE_PROGRAM}")
        set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ${CCACHE_PROGRAM})
        set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ${CCACHE_PROGRAM})
    endif()
endif()

# message(STATUS "CMAKE_MODULE_PATH: ${CMAKE_MODULE_PATH}")


#===== SubModules ======================

# add_subdirectory(math)


#===== Source Files ====================

# aux_source_directory(src sources)
file(GLOB_RECURSE sources CONFIGURE_DEPENDS src/*.cpp src/*.h include/*.h)

add_executable(${PROJECT_NAME} ${sources})

target_include_directories(${PROJECT_NAME} PUBLIC include)


#===== Cached Options ==================

# option(WITH_TBB "set to ON to enable TBB, OFF to disable TBB." ON)
# if (WITH_TBB)
#     target_compile_definitions(${PROJECT_NAME} PUBLIC WITH_TBB)
#     find_package(TBB REQUIRED)
#     target_link_libraries(${PROJECT_NAME} PUBLIC TBB:tbb)
# endif()


#===== Find Packages ===================

# find_package(Eigen3 COMPONENTS Eigen REQUIRED)
# target_link_libraries(${PROJECT_NAME} PUBLIC Eigen3::Eigen)


#===== Output Directories ==============

set_target_properties(${PROJECT_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_SOURCE_DIR}/bin/Release)
set_target_properties(${PROJECT_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG   ${CMAKE_SOURCE_DIR}/bin/Debug)
if(WIN32)
    set_target_properties(${PROJECT_NAME} PROPERTIES VS_DEBUGGER_WORKING_DIRECTORY    ${CMAKE_SOURCE_DIR}/bin/Debug)
elseif(UNIX)
endif()
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin/Release)
else() # Debug
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin/Debug)
endif()
message(STATUS "Set binary output directory to ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")


#===== Copy Commands ===================

# cmake configure time copy
if (EXISTS "${CMAKE_BINARY_DIR}/compile_commands.json")
    file(COPY "${CMAKE_BINARY_DIR}/compile_commands.json" DESTINATION ${CMAKE_SOURCE_DIR})
endif()

# cmake build time copy
# file(GLOB DLLS_TO_COPY ${CMAKE_SOURCE_DIR}/lib/*.dll)
# ADD_CUSTOM_COMMAND(
#     TARGET ${PROJECT_NAME}
#     POST_BUILD
#     COMMAND ${CMAKE_COMMAND} -E copy_if_different
#     ${DLLS_TO_COPY}
#     $<TARGET_FILE_DIR:${PROJECT_NAME}>
#     COMMENT "Copying dlls... to target directory"
# )


#======================================
#===== CMake Cheat Sheet ==============
#
# CMAKE_BINARY_DIR: the directory where the compiled files are stored
# CMAKE_SOURCE_DIR: the directory where the top-level CMakeLists.txt file is located
# CMAKE_CURRENT_BINARY_DIR: the directory where the currently processed CMakeLists.txt file is compiled
# CMAKE_CURRENT_SOURCE_DIR: the directory where the currently processed CMakeLists.txt file is located
# CMAKE_MODULE_PATH: a list of directories containing additional CMake modules
# CMAKE_CURRENT_LIST_FILE: the full path to the CMakeLists.txt file currently being processed
# CMAKE_CURRENT_LIST_DIR: the directory of the CMakeLists.txt file currently being processed
#
# PROJECT_NAME: the name of the project defined by the project() command
# PROJECT_SOURCE_DIR: the directory where the top-level CMakeLists.txt file is located
# PROJECT_BINARY_DIR: the directory where the compiled files are stored
#
# CMAKE_INCLUDE_PATH: the list of directories that are searched for include files
# CMAKE_LIBRARY_PATH: the list of directories that are searched for libraries
#
# CMAKE_SYSTEM: true if CMake is built for the system
# CMAKE_SYSTEM_NAME: the name of the system CMake is running on
# CMAKE_SYSTEM_VERSION: the version of the system CMake is running on
# CMAKE_SYSTEM_PROCESSOR: the processor CMake is running on
#
# UNIX: true if system is UNIX-like
# WIN32: true if system is Windows
# APPLE: true if system is Apple
# MSVC: true if the compiler is MSVC
# MSVC_VERSION: the version of MSVC
# CMAKE_C_COMPILER: the compiler used for C
# CMAKE_CXX_COMPILER: the compiler used for C++
#
# ======================================

