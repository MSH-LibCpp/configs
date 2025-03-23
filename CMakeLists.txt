cmake_minimum_required(VERSION 3.20)

set(PROJECT_VERSION "0.0.1")

project(
    msh_utils
    VERSION ${PROJECT_VERSION}
    LANGUAGES CXX
)

# C++ Standard Configuration
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Project Options
option(ENABLE_COVERAGE "Enable coverage reporting" ON)
option(ENABLE_STATIC_ANALYSIS "Enable static analysis" ON)
option(BUILD_TESTING "Build test suite" ON)

# Include custom CMake modules
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(cppcheck)
include(opencppcoverage)

# Testing
if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
    include(CTest)
    if(BUILD_TESTING)
        # Find Catch2
        find_package(Catch2 3.5.3 REQUIRED)

        add_subdirectory(tests)
    endif()
endif()
