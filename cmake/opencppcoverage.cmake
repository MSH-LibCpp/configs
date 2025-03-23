# configure_opencppcoverage(TEST_TARGET [SOURCES_DIRS])
# Note that SOURCES_DIRS should be absolute paths not relative paths
function(configure_opencppcoverage TEST_TARGET)
    if(WIN32)
        find_program(OPENCPPCOVERAGE OpenCppCoverage HINTS "C:\\Program Files\\OpenCppCoverage" "$ENV{MSH_ROOT_PATH}/tools/coverage")

        if(OPENCPPCOVERAGE)
            message(STATUS ">>> Found OpenCppCoverage program: ${OPENCPPCOVERAGE}")

            # Normalize paths for Windows
            set(ModulePathString ${CMAKE_CURRENT_BINARY_DIR}/Debug)
            string(REGEX REPLACE "/" "\\\\" ModulePathString ${ModulePathString})
            message(STATUS ">>> Module path string: ${ModulePathString}")

            # Get source directories from the arguments
            set(SOURCES_ARGS "")
            foreach(arg IN LISTS ARGN)
                string(REGEX REPLACE "/" "\\\\" SOURCE_DIR ${arg})
                list(APPEND SOURCES_ARGS "${SOURCE_DIR}")
            endforeach()

            # Remove duplicates from source directories
            list(REMOVE_DUPLICATES SOURCES_ARGS)

            # Build the sources arguments
            set(SOURCES_CMD "")
            foreach(SOURCE_DIR ${SOURCES_ARGS})
                list(APPEND SOURCES_CMD "--sources")
                list(APPEND SOURCES_CMD "${SOURCE_DIR}")
            endforeach()

            # Add coverage command to test target
            add_custom_command(
                TARGET ${TEST_TARGET} POST_BUILD
                COMMAND ${OPENCPPCOVERAGE}
                --modules ${ModulePathString}
                ${ModulePathString}\\$<TARGET_FILE_NAME:${TEST_TARGET}>
                --export_type=html:${CMAKE_BINARY_DIR}/${TEST_TARGET}_coverage_report
                ${SOURCES_CMD}
                COMMENT "Generating coverage report..."
                VERBATIM
            )

            message(STATUS ">>> Coverage report will be generated in: ${CMAKE_BINARY_DIR}/${TEST_TARGET}_coverage_report")
            message(STATUS ">>> Source directories being monitored:")
            foreach(SOURCE_DIR ${SOURCES_ARGS})
                message(STATUS "    - ${SOURCE_DIR}")
            endforeach()
        else()
            message(WARNING ">>>> OpenCppCoverage program not found")
        endif()
    endif()
endfunction()
