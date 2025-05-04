# ===========================
# configure_cppcheck
# ===========================
# Configures a cppcheck static analysis target for a given target.
#
# Usage:
#   configure_cppcheck(
#       TARGET      <target_name>                   # Required
#       PATHS       <list of files or directories>  # Optional
#   )
#
# Notes:
# - Accepts both directories (recursively globs *.cpp/h/hpp) and individual files.
# - Automatically excludes non-existent paths with a warning.
# - Only activates in Debug builds.
# - Creates a <target_name>_cppcheck custom target.
function(configure_cppcheck)
    # Parses the arguments
    set(options)
    set(oneValueArgs TARGET)
    set(multiValueArgs PATHS)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT ARG_TARGET)
        message(FATAL_ERROR ">>>>> configure_cppcheck: TARGET argument is required.")
    endif()

    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        find_program(CPPCHECK_EXECUTABLE cppcheck)

        if(NOT CPPCHECK_EXECUTABLE)
            message(WARNING ">>>> cppcheck not found. Static analysis will not be performed.")
            return()
        endif()

        message(STATUS ">>> Found cppcheck: ${CPPCHECK_EXECUTABLE}")

        set(SOURCES_ARGS "")

        # Also include source files already registered to the target (optional)
        get_target_property(EXISTING_SOURCES ${ARG_TARGET} SOURCES)
        if(EXISTING_SOURCES)
            list(APPEND SOURCES_ARGS ${EXISTING_SOURCES})
        endif()

        # Process the user-provided paths (files or directories)
        foreach(path IN LISTS ARG_PATHS)
            if(NOT EXISTS "${path}")
                message(WARNING ">>>> Path does not exist: ${path}")
                continue()
            endif()

            if(IS_DIRECTORY "${path}")
                # Directory: recursively glob files
                file(GLOB_RECURSE DIR_CPP "${path}/*.cpp")
                file(GLOB_RECURSE DIR_H "${path}/*.h")
                file(GLOB_RECURSE DIR_HPP "${path}/*.hpp")
                list(APPEND SOURCES_ARGS ${DIR_CPP} ${DIR_H} ${DIR_HPP})
            elseif(IS_ABSOLUTE "${path}" OR IS_ABSOLUTE "${CMAKE_CURRENT_SOURCE_DIR}/${path}")
                # File: add directly
                list(APPEND SOURCES_ARGS "${path}")
            else()
                # Relative file path — resolve to absolute based on current dir
                get_filename_component(abs_path "${path}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
                list(APPEND SOURCES_ARGS "${abs_path}")
            endif()
        endforeach()

        # Remove duplicates
        list(REMOVE_DUPLICATES SOURCES_ARGS)

        if(SOURCES_ARGS)
            message(STATUS ">>> Files for cppcheck on target '${ARG_TARGET}':")
            foreach(src IN LISTS SOURCES_ARGS)
                message(STATUS "    ${src}")
            endforeach()

            # Add custom cppcheck target
            add_custom_target(${ARG_TARGET}_cppcheck
                COMMAND ${CPPCHECK_EXECUTABLE}
                --enable=all
                --language=c++
                --std=c++17
                --inconclusive
                --suppress=missingIncludeSystem
                --suppress=missingInclude
                --suppress=unusedFunction
                --verbose
                ${SOURCES_ARGS}
                WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                COMMENT "-------- Running cppcheck for ${ARG_TARGET} --------"
                VERBATIM
            )

            # Optional: make cppcheck run with the target
            add_dependencies(${ARG_TARGET} ${ARG_TARGET}_cppcheck)
        else()
            message(WARNING ">>>> No valid source files found for cppcheck on '${ARG_TARGET}'.")
        endif()
    endif()
endfunction()
