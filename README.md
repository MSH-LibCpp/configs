# MSH Utils

A collection of utility functions and classes for C++ development.

## Features

- Header-only library
- Modern C++ (C++17)
- Comprehensive test coverage
- Static analysis with cppcheck
- Code coverage reporting with OpenCppCoverage

## Requirements

- C++17 compatible compiler
- CMake 3.14 or higher
- Catch2 3.5.3 or higher (for testing)
- cppcheck (optional, for static analysis)
- OpenCppCoverage (optional, for code coverage)

## Building

```bash
# Create build directory
cmake -B build -S .

# Build the project
cmake --build build

# Run tests
ctest --test-dir build

# Generate coverage report (Windows only)
cmake --build build --target byte_array_test
```

## Testing

The project uses Catch2 for unit testing. Tests are located in the `tests` directory.

### Running Tests

```bash
# Run all tests
ctest --test-dir build

# Run specific test
build/tests/Debug/byte_array_test.exe
```

### Code Coverage

Code coverage reports are generated automatically when building tests with coverage enabled:

```bash
# Configure with coverage enabled
cmake -B build -S . -DENABLE_COVERAGE=ON

# Build and run tests
cmake --build build --target byte_array_test
```

The coverage report will be available in `build/byte_array_test_coverage_report/index.html`.

## Static Analysis

Static analysis is performed using cppcheck:

```bash
# Configure with cppcheck
cmake -B build -S .

# Run static analysis
cmake --build build
```

## Installation

```bash
# Install the library
cmake --install build

# Use in your project
find_package(msh_utils REQUIRED)
target_link_libraries(your_target PRIVATE msh::utils)
```

## CMake
You can also use the `msh::utils` interface target in CMake.

```cpp
# CMakeLists.txt
find_package(utilities REQUIRED)
...
add_library(foo ...)
...
target_link_libraries(foo PRIVATE msh::utils)
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
Also review the [requirement](#requirements)'s section for third-party licenses.