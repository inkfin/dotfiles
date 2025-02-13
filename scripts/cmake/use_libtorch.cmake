# FETCHCONTENT_TRY_FIND_PACKAGE_MODE = OPT_IN, ALWAYS, NEVER
# OPT_IN: FetchContent will only try to find the package if the user explicitly asks for it.
# ALWAYS: FetchContent will always try to find the package.
# NEVER: FetchContent will never try to find the package.

include(FetchContent)

## LibTorch
set(LIBTORCH_VERSION "2.6.0")
set(LIBTORCH_CUDA_VERSION "126")
set(LIBTORCH_URL "https://download.pytorch.org/libtorch/cu${LIBTORCH_CUDA_VERSION}/libtorch-cxx11-abi-shared-with-deps-${LIBTORCH_VERSION}%2Bcu${LIBTORCH_CUDA_VERSION}.zip")

FetchContent_Declare(
    libtorch
    URL             ${LIBTORCH_URL}
    URL_HASH        SHA256=15708d647d720eb703994f022488bca9ae29a07cf19e76e8b218d0a07be2a943
    DOWNLOAD_DIR    ${CMAKE_BINARY_DIR}/libtorch_download
    DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    SOURCE_DIR      ${CMAKE_SOURCE_DIR}/third_party/libtorch
    FIND_PACKAGE_ARGS NAMES Torch CONFIG REQUIRED
)

# Disable libtorch cmake false positives
# > https://stackoverflow.com/questions/79273676/how-to-avoid-find-package-handle-standard-args-package-name-warning
set(FPHSA_NAME_MISMATCHED ON)

FetchContent_MakeAvailable(libtorch)

if(DEFINED libtorch_SOURCE_DIR AND NOT libtorch_SOURCE_DIR STREQUAL "")
    message(STATUS "📌 LibTorch will be available at ${libtorch_SOURCE_DIR}")
else()
    message(STATUS "🖥 Using LibTorch from system")
endif()

# Use cuDNN
# set(CAFFE2_USE_CUDNN ON)

# Use system NVTX3
# set(USE_SYSTEM_NVTX ON)
# set nvtx3_dir or append cuda path to CMAKE_PREFIX_PATH

