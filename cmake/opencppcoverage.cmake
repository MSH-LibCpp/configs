function(configure_opencppcoverage TEST_TARGET LIB_TARGET)
    if(WIN32)
        find_program(OPENCPPCOVERAGE OpenCppCoverage HINTS "C:\\Program Files\\OpenCppCoverage" "$ENV{MSH_ROOT_PATH}/tools/coverage")

        if(OPENCPPCOVERAGE)
            message(STATUS "> Found OpenCppCoverage program: ${OPENCPPCOVERAGE}")
            
            # Normalize paths for Windows
            set(ModulePathString ${CMAKE_BINARY_DIR}/tests/Debug)
            string(REGEX REPLACE "/" "\\\\" ModulePathString ${ModulePathString})
            
            # Get source directories from the library target
            get_target_property(LIB_SOURCES ${LIB_TARGET} SOURCES)
            get_target_property(LIB_SOURCE_DIR ${LIB_TARGET} SOURCE_DIR)
            
            # Convert source files to their directories
            set(SOURCES_ARGS "")
            foreach(SOURCE ${LIB_SOURCES})
                get_filename_component(SOURCE_DIR "${LIB_SOURCE_DIR}/${SOURCE}" DIRECTORY)
                string(REGEX REPLACE "/" "\\\\" SOURCE_DIR ${SOURCE_DIR})
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
            
            message(STATUS "> Coverage report will be generated in: ${CMAKE_BINARY_DIR}/${TEST_TARGET}_coverage_report")
            message(STATUS "> Source directories being monitored:")
            foreach(SOURCE_DIR ${SOURCES_ARGS})
                message(STATUS "  - ${SOURCE_DIR}")
            endforeach()
        else()
            message(STATUS "> OpenCppCoverage program not found")
        endif()
    endif()
endfunction() 