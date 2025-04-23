# FETCHCONTENT_TRY_FIND_PACKAGE_MODE = OPT_IN, ALWAYS, NEVER
# OPT_IN: FetchContent will only try to find the package if the user explicitly asks for it.
# ALWAYS: FetchContent will always try to find the package.
# NEVER: FetchContent will never try to find the package.

include(FetchContent)

## Dear ImGui
FetchContent_Declare(
    ImGui
    GIT_REPOSITORY  https://github.com/ocornut/imgui.git
    GIT_TAG         docking # or master
    GIT_SHALLOW     TRUE
    GIT_PROGRESS    TRUE
    SOURCE_DIR      ${CMAKE_SOURCE_DIR}/third_party/imgui
)
FetchContent_MakeAvailable(ImGui)

set(IMGUI_DIR ${CMAKE_SOURCE_DIR}/third_party/imgui)
message(STATUS "📌 ImGui will be available at ${IMGUI_DIR}")


## Configurations

# ---- Options ----
option(IMGUI_BACKEND_GLFW_OPENGL3   "Use GLFW + OpenGL3 backend for ImGui" OFF)
option(IMGUI_BACKEND_GLFW_VULKAN    "Use GLFW + Vulkan backend for ImGui" OFF)
option(IMGUI_BACKEND_GLFW_WGPU      "Use GLFW + WebGPU backend for ImGui" OFF)

# ---- IMGUI Core ----
set(IMGUI_INCLUDE_DIRS
    ${IMGUI_DIR}
    ${IMGUI_DIR}/backends
)
include_directories(${IMGUI_INCLUDE_DIRS})
set(IMGUI_SOURCES
    ${IMGUI_DIR}/imgui.cpp
    ${IMGUI_DIR}/imgui_draw.cpp
    ${IMGUI_DIR}/imgui_widgets.cpp
    ${IMGUI_DIR}/imgui_tables.cpp
    # ${IMGUI_DIR}/imgui_demo.cpp
)

# ---- Backends ----
if(IMGUI_BACKEND_GLFW_OPENGL3)
    list(APPEND IMGUI_SOURCES
        ${IMGUI_DIR}/backends/imgui_impl_glfw.cpp
        ${IMGUI_DIR}/backends/imgui_impl_opengl3.cpp
    )
endif()

if(IMGUI_BACKEND_GLFW_VULKAN)
    list(APPEND IMGUI_SOURCES
        ${IMGUI_DIR}/backends/imgui_impl_glfw.cpp
        ${IMGUI_DIR}/backends/imgui_impl_vulkan.cpp
    )

    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DVK_PROTOTYPES")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DVK_PROTOTYPES")
endif()

if(IMGUI_BACKEND_GLFW_WGPU)
    list(APPEND IMGUI_SOURCES
        ${IMGUI_DIR}/backends/imgui_impl_glfw.cpp
        ${IMGUI_DIR}/backends/imgui_impl_wgpu.cpp
    )

    # WGPU Configuration
    # ...
endif()

# ---- Print all options ----
message(STATUS "IMGUI_BACKEND_GLFW_OPENGL3: ${IMGUI_BACKEND_GLFW_OPENGL3}")
message(STATUS "IMGUI_BACKEND_GLFW_VULKAN:  ${IMGUI_BACKEND_GLFW_VULKAN}")
message(STATUS "IMGUI_BACKEND_GLFW_WGPU:    ${IMGUI_BACKEND_GLFW_WGPU}")
