cmake_minimum_required(VERSION 3.15)

set(CMAKE_CXX_STANDARD 11)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON) #生成 compile_commands.json 以便 clangd 正确读取头文件
set(CMAKE_CXX_EXTENSIONS OFF)

# if (NOT CMAKE_TOOLCHAIN_FILE)
#     set(CMAKE_TOOLCHAIN_FILE "vcpkg/scripts/buildsystems/vcpkg.cmake")
# endif()

project(HelloWorld LANGUAGES CXX VERSION 0.1)

if (PROJECT_BINARY_DIR STREQUAL PROJECT_SOURCE_DIR)
    message(SEND_ERROR "The binary directory of CMake cannot be the same as source directory!")
endif()

if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

if (WIN32)
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



# 添加子目录,作用相当于进入子目录里面，展开子目录的CMakeLists.txt
# 同时执行，子目录中的CMakeLists.txt一般是编译成一个库，作为一个模块
# add_subdirectory(math)

# find_package(Eigen3 COMPONENTS Eigen REQUIRED)


# add_library(mylib SHARED/STATIC/OBJECT 源码列表)


# aux_source_directory(src sources)
file(GLOB_RECURSE sources CONFIGURE_DEPENDS src/*.cpp src/*.h)

add_executable(${PROJECT_NAME} ${sources})

target_include_directories(${PROJECT_NAME} PUBLIC include)

# 链接库，PUBLIC/PRIVATE 指定是否传播
#target_link_libraries(${PROJECT_NAME} PUBLIC mylib Eigen3::Eigen)

# 设置输出目录
set_target_properties(${PROJECT_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_CURRENT_SOURCE_DIR}/bin/Release)
set_target_properties(${PROJECT_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG   ${CMAKE_CURRENT_SOURCE_DIR}/bin/Debug)
if(WIN32)
    set_target_properties(${PROJECT_NAME} PROPERTIES VS_DEBUGGER_WORKING_DIRECTORY    ${CMAKE_CURRENT_SOURCE_DIR}/bin/Debug)
elseif(UNIX)
endif()
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/bin/Release)
else() # Debug
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/bin/Debug)
endif()
message(STATUS "Set binary output directory to ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")


# CMake Cache 默认值
# option(WITH_TBB "set to ON to enable TBB, OFF to disable TBB." ON)
# if (WITH_TBB)
# target_compile_definitions(${PROJECT_NAME} PUBLIC WITH_TBB)
# find_package(TBB REQUIRED)
# target_link_libraries(${PROJECT_NAME} PUBLIC TBB:tbb)
# endif()


# if (EXISTS "${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json")
#     ADD_CUSTOM_COMMAND(
#         TARGET ${PROJECT_NAME}
#         POST_BUILD
#         COMMAND ${CMAKE_COMMAND} -E copy_if_different
#         ${CMAKE_BINARY_DIR}/compile_commands.json
#         ${CMAKE_SOURCE_DIR}
#     )
# endif()
