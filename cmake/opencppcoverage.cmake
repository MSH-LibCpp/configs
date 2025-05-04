# ===========================
# configure_opencppcoverage
# ===========================
# Configures a custom post-build command to run OpenCppCoverage for a given target.
#
# Usage:
#   configure_opencppcoverage(
#       TARGET   <target_name>                                         # Required
#       SOURCES  <absolute source directories to include in coverage>  # Optional : Uses the target's sources
#   )
#
# Notes:
# - Only activates on Windows in Debug builds.
# - All paths in SOURCES must be absolute.
# - Accepts only directories, not individual source files.
function(configure_opencppcoverage)
    # Parses the arguments
    set(options)
    set(oneValueArgs TARGET)
    set(multiValueArgs SOURCES)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT ARG_TARGET)
        message(FATAL_ERROR ">>>>> configure_opencppcoverage: TARGET argument is required.")
    endif()

    # Only runs on Windows in Debug builds
    if(WIN32 AND CMAKE_BUILD_TYPE STREQUAL "Debug")
        # Tries to locate OpenCppCoverage executable
        find_program(OPENCPPCOVERAGE OpenCppCoverage
            HINTS
            "C:\\Program Files\\OpenCppCoverage"
            "$ENV{MSH_ROOT_PATH}/tools/coverage"
        )

        if(NOT OPENCPPCOVERAGE)
            message(WARNING ">>>> OpenCppCoverage not found — coverage will not be enabled.")
            return()
        endif()

        message(STATUS ">>> Found OpenCppCoverage: ${OPENCPPCOVERAGE}")

        # Normalizes the binary directory path (CMake uses forward slashes by default)
        set(ModulePathString "${CMAKE_CURRENT_BINARY_DIR}")
        string(REPLACE "/" "\\" ModulePathString "${ModulePathString}")

        message(STATUS ">>> Coverage output directory: ${CMAKE_BINARY_DIR}/${ARG_TARGET}_coverage_report")

        # Validates and normalize source directories
        set(SOURCES_ARGS "")
        foreach(dir IN LISTS ARG_SOURCES)
            if(NOT IS_ABSOLUTE "${dir}")
                message(FATAL_ERROR ">>>>> Source path '${dir}' must be an absolute path.")
            endif()

            if(NOT IS_DIRECTORY "${dir}")
                message(WARNING ">>>> Skipping: '${dir}' is not a valid directory.")
                continue()
            endif()

            # Normalizes slashes for Windows
            string(REPLACE "/" "\\" norm_path "${dir}")
            list(APPEND SOURCES_ARGS "${norm_path}")
        endforeach()

        list(REMOVE_DUPLICATES SOURCES_ARGS)

        if(SOURCES_ARGS STREQUAL "")
            message(WARNING ">>>> No valid source directories provided for coverage.")
            return()
        endif()

        # Constructs --sources <dir> arguments for OpenCppCoverage
        set(SOURCES_CMD "")
        foreach(src_dir IN LISTS SOURCES_ARGS)
            list(APPEND SOURCES_CMD "--sources" "${src_dir}")
        endforeach()

        # Registers a POST_BUILD step to run OpenCppCoverage
        add_custom_command(
            TARGET ${ARG_TARGET} POST_BUILD
            COMMAND ${OPENCPPCOVERAGE}
            --modules "${ModulePathString}"
            "${ModulePathString}\\$<TARGET_FILE_NAME:${ARG_TARGET}>"
            --export_type=html:${CMAKE_BINARY_DIR}/${ARG_TARGET}_coverage_report
            ${SOURCES_CMD}
            COMMENT "Generating OpenCppCoverage report for '${ARG_TARGET}'..."
            VERBATIM
        )

        # Prints out for user clarity
        message(STATUS ">>> OpenCppCoverage will monitor:")
        foreach(src_dir IN LISTS SOURCES_ARGS)
            message(STATUS "    - ${src_dir}")
        endforeach()
    endif()
endfunction()
