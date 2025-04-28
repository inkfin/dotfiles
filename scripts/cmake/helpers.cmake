function(set_binary_output_dirs TARGET OUTPUT_BASE)
    set(_outdir "${CMAKE_SOURCE_DIR}/${OUTPUT_BASE}")

    set_target_properties(${TARGET} PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY_RELEASE "${_outdir}/Release"
        RUNTIME_OUTPUT_DIRECTORY_DEBUG   "${_outdir}/Debug"
    )

    if(WIN32)
        set_target_properties(${TARGET} PROPERTIES
            VS_DEBUGGER_WORKING_DIRECTORY "${_outdir}/Debug"
        )
    endif()

    if(CMAKE_BUILD_TYPE STREQUAL "Release")
        set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${_outdir}/Release")
    else()
        set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${_outdir}/Debug")
    endif()

    message(STATUS "Set binary output directory for target ${TARGET} -> ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
endfunction()
