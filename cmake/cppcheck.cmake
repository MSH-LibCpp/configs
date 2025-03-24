# configure_cppcheck(TARGET [SOURCES_DIRS] [HEADERS_DIRS])
# There is no need to pass absolute paths for SOURCES_DIRS and HEADERS_DIRS but try to use absolute paths for best practice
function(configure_cppcheck TARGET)
    find_program(CPPCHECK_EXECUTABLE cppcheck)

    if(CPPCHECK_EXECUTABLE)
        message(STATUS ">>> Found cppcheck: ${CPPCHECK_EXECUTABLE}")

        # Get source directories from the target
        set(SOURCES_ARGS "")
        foreach(arg IN LISTS ARGN)
            file(GLOB_RECURSE TARGET_SOURCES "${arg}/*.cpp")
            list(APPEND SOURCES_ARGS ${TARGET_SOURCES})
            file(GLOB_RECURSE TARGET_HEADERS "${arg}/*.h")
            list(APPEND SOURCES_ARGS ${TARGET_HEADERS})
            file(GLOB_RECURSE TARGET_HEADERS_ONLY "${arg}/*.hpp")
            list(APPEND SOURCES_ARGS ${TARGET_HEADERS_ONLY})
        endforeach()

        # Remove duplicates from source directories
        list(REMOVE_DUPLICATES SOURCES_ARGS)
        message(STATUS ">>> Source directories for cppcheck: ${SOURCES_ARGS}")

        if(SOURCES_ARGS)
            # Create a custom target for cppcheck
            add_custom_target(${TARGET}_cppcheck
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
                COMMENT "-------- Running cppcheck for ${TARGET} --------"
                VERBATIM
            )

            add_dependencies(${TARGET} ${TARGET}_cppcheck)
        else()
            message(WARNING ">>>> Target ${TARGET} has no sources for cppcheck.")
        endif()
    else()
        message(WARNING ">>>> cppcheck not found. Static analysis will not be performed.")
    endif()
endfunction()
