cmake_minimum_required(VERSION 3.20.0)

set(PROJECT_VERSION "0.0.1")

project(
    TEST_PROJECT
    VERSION ${PROJECT_VERSION}
    LANGUAGES C CXX
)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(FETCHCONTENT_FULLY_DISCONNECTED "" ON)
option(ENABLE_STATIC_ANALYSIS_USING_CPPCHECK "" ON)
option(RUN_OPENCPPCOVERAGE "" ON)
option(BUILD_ALL_TESTS "" ON)

include(${PROJECT_SOURCE_DIR}/dependencies.cmake)

if(BUILD_ALL_TESTS)
    enable_testing()
    include(CTest)
endif()

add_dependency(plog https://github.com/lvgl/lvgl.git 9.2.2 "")

# Add the executable
set(TEST_TARGET tst_trgt)
add_executable(${TEST_TARGET} main.cpp)

if(ENABLE_STATIC_ANALYSIS_USING_CPPCHECK)
    add_cppcheck_target(${TEST_TARGET})
endif()

if(RUN_OPENCPPCOVERAGE)
    addOpenCppCoverage(${TEST_TARGET} ${PROJECT_SOURCE_DIR}/src/dto/src "")
endif()