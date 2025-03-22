function(configure_cppcheck)
    find_program(CPPCHECK_EXECUTABLE cppcheck)

    if(CPPCHECK_EXECUTABLE)
        # Set cppcheck options for build-time checks
        set(CMAKE_CXX_CPPCHECK
            ${CPPCHECK_EXECUTABLE}
            --enable=all
            --inconclusive
            --force
            --inline-suppr
            --suppress=missingIncludeSystem
            --suppress=unmatchedSuppression
            --suppress=unusedFunction
            --verbose
            PARENT_SCOPE
        )
    else()
        message(WARNING "cppcheck not found. Static analysis will not be performed.")
    endif()
endfunction()
