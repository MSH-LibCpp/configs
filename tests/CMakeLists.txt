# Create test executable
add_executable(calculator_test
    calculator_test.cpp
)

# Link the test executable with the calculator library and Catch2
target_link_libraries(calculator_test
    PRIVATE
        calculator
        Catch2::Catch2WithMain
)

# Add test to CTest
add_test(NAME calculator_test COMMAND calculator_test)

# Configure OpenCppCoverage
include(${CMAKE_SOURCE_DIR}/cmake/opencppcoverage.cmake)
configure_opencppcoverage(calculator_test calculator) 