# Include the FetchContent module
include(FetchContent)

if(NOT DEFINED ENV{MSH_ROOT_PATH})
    # The environment variable does not exist
    message(FATAL_ERROR ">>>>> Environment variable MSH_ROOT_PATH is not defined.")
endif()

# Add a function to handle dependencies
function(add_dependency repo_name repo_url repo_tag local_path)
    # Check if the library exists locally
    if(FETCHCONTENT_FULLY_DISCONNECTED)
        if(local_path STREQUAL "")
            set(local_path "$ENV{MSH_ROOT_PATH}/external/${repo_name}")
        endif()
        if(EXISTS "${local_path}")
            # Specify the local directory as the source for FetchContent
            message(STATUS "> Found offline repository for ${repo_name} at ${local_path}")
            # Set the source directory for FetchContent
            set(${repo_name}_SOURCE_DIR "$ENV{MSH_ROOT_PATH}/external/${repo_name}" CACHE STRING "" FORCE)
        else()
            message(FATAL_ERROR ">>>>> Offline repository for ${repo_name} not found. Double check the repository path: $ENV{MSH_ROOT_PATH}/external/${repo_name} or make the FETCHCONTENT_FULLY_DISCONNECTED flag OFF.")
        endif()
    endif()

    # FetchContent declaration for the dependency
    fetchcontent_declare(
        ${repo_name}
        SOURCE_DIR ${${repo_name}_SOURCE_DIR}
        GIT_REPOSITORY ${repo_url}
        GIT_TAG ${repo_tag} # Specify the version/tag you want to use
    )

    fetchcontent_makeavailable(${repo_name})
endfunction()

if(ENABLE_STATIC_ANALYSIS_USING_CPPCHECK)
    function(add_cppcheck_target TARGET)

        find_program(CPPCHECK_EXECUTABLE cppcheck)

        if(NOT CPPCHECK_EXECUTABLE)
            message("> Cppcheck not found! Please install Cppcheck.")
        endif()

        get_target_property(SOURCES ${TARGET} SOURCES)

        if(SOURCES)
            add_custom_target(${TARGET}_cppcheck # PRE_BUILD
                COMMAND ${CPPCHECK_EXECUTABLE}
                --enable=all
                --std=c++17 # --language=c++
                --inconclusive
                --suppress=missingIncludeSystem
                --suppress=missingInclude
                --suppress=unusedFunction
                --verbose
                ${SOURCES}
                WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                COMMENT "-------- Running cppcheck --------"
                VERBATIM
            )

            add_dependencies(${TARGET} ${TARGET}_cppcheck)
        else()
            message(WARNING ">>> Target ${TARGET} has no sources for Cppcheck.")
        endif()
    endfunction()
endif()

if(RUN_OPENCPPCOVERAGE)
    function(addOpenCppCoverage PROJECT_TEST_TARGET MODULE_SOURCE_PATH_LIST OpenCppCoverage_PATH)
        # -- using OpenCppCoverage to generate export report of code coverage
        if(WIN32)
            find_program(OPENCPPCOVERAGE OpenCppCoverage HINTS "C:\\Program Files\\OpenCppCoverage" "$ENV{MSH_ROOT_PATH}/tools/coverage" ${OpenCppCoverage_PATH})

            if(OPENCPPCOVERAGE)
                message(STATUS "> Found OpenCppCoverage program: ${OPENCPPCOVERAGE}")
                # -- because this tools could not accept '/' seprator
                set(ModulePathString ${CMAKE_CURRENT_BINARY_DIR}/Debug)
                string(REGEX REPLACE "/" "\\\\" ModulePathString ${ModulePathString})

                message(STATUS "> ModulePathString: " ${ModulePathString})

                set(SOURCES_ARGS "")
                foreach(SOURCE_PATH ${MODULE_SOURCE_PATH_LIST})
                    string(REGEX REPLACE "/" "\\\\" SOURCE_PATH ${SOURCE_PATH})
                    list(APPEND SOURCES_ARGS "${SOURCE_PATH}")
                endforeach()

                list(LENGTH SOURCES_ARGS SOURCES_ARGS_LEN)

                if(${SOURCES_ARGS_LEN} EQUAL 1)
                    list(GET SOURCES_ARGS 0 FIRST_PATH)
                    message(STATUS "> SOURCES_ARGS[${SOURCES_ARGS_LEN}]: ${FIRST_PATH}")
                    add_custom_command(
                        TARGET ${PROJECT_TEST_TARGET} POST_BUILD
                        COMMAND ${OPENCPPCOVERAGE} --modules ${ModulePathString} ${ModulePathString}\\$<TARGET_FILE_NAME:${PROJECT_TEST_TARGET}> --export_type
                        html:${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_TEST_TARGET}_coverage_report --sources "${FIRST_PATH}"
                    )
                elseif(${SOURCES_ARGS_LEN} EQUAL 2)
                    list(GET SOURCES_ARGS 0 FIRST_PATH)
                    list(GET SOURCES_ARGS 1 SECOND_PATH)
                    message(STATUS "> SOURCES_ARGS[${SOURCES_ARGS_LEN}]: ${FIRST_PATH}, ${SECOND_PATH}")
                    add_custom_command(
                        TARGET ${PROJECT_TEST_TARGET} POST_BUILD
                        COMMAND ${OPENCPPCOVERAGE} --modules ${ModulePathString} ${ModulePathString}\\$<TARGET_FILE_NAME:${PROJECT_TEST_TARGET}> --export_type
                        html:${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_TEST_TARGET}_coverage_report --sources "${FIRST_PATH}" --sources "${SECOND_PATH}")
                elseif(${SOURCES_ARGS_LEN} EQUAL 3)
                    list(GET SOURCES_ARGS 0 FIRST_PATH)
                    list(GET SOURCES_ARGS 1 SECOND_PATH)
                    list(GET SOURCES_ARGS 2 THIRD_PATH)
                    message(STATUS "> SOURCES_ARGS[${SOURCES_ARGS_LEN}]: ${FIRST_PATH}, ${SECOND_PATH}, ${THIRD_PATH}")
                    add_custom_command(
                        TARGET ${PROJECT_TEST_TARGET} POST_BUILD
                        COMMAND ${OPENCPPCOVERAGE} --modules ${ModulePathString} ${ModulePathString}\\$<TARGET_FILE_NAME:${PROJECT_TEST_TARGET}> --export_type
                        html:${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_TEST_TARGET}_coverage_report
                        --sources ${FIRST_PATH} --sources ${SECOND_PATH} --sources ${THIRD_PATH}
                    )
                else()
                    message(FATAL_ERROR ">>>>> Too many arguments: ${SOURCES_ARGS_LEN}")
                endif()
            else()
                message(STATUS "> OpenCppCoverage program not found")
            endif()
        endif()
    endfunction()
endif()