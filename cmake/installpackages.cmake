# Sets standard install directories:
# - ${CMAKE_INSTALL_LIBDIR}     → lib/     (for static/shared libraries)
# - ${CMAKE_INSTALL_INCLUDEDIR} → include/ (for headers)
# - ${CMAKE_INSTALL_BINDIR}     → bin/     (for executables, DLLs, plugins)
include(GNUInstallDirs)

# ========================
# install_library_requirements
# ========================
# Handles the common tasks for installing a CMake package:
# - headers
# - version files
# - exported targets
# - config .cmake files with dependency forwarding
#
# Usage:
# install_library_requirements(
#   TARGET        <target name>                     # Required
#   DEPENDENCIES  <list of dependency targets>      # Optional
#   TYPE          <STATIC|SHARED|MODULE|INTERFACE>  # Optional/Informative
# )
function(install_library_requirements)
    # Parses arguments
    set(options)
    set(oneValueArgs TARGET TYPE)
    set(multiValueArgs DEPENDENCIES)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT ARG_TARGET)
        message(FATAL_ERROR ">>>>> install_library_requirements: TARGET is required.")
    endif()

    include(CMakePackageConfigHelpers)

    # Installs all headers from the 'include/' directory
    install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

    # Defines the install location for package config files
    set(CONFIG_INSTALL_DIR ${CMAKE_INSTALL_LIBDIR}/cmake/${ARG_TARGET})

    # Generates a version file for use with find_package()
    write_basic_package_version_file(
        "${CMAKE_CURRENT_BINARY_DIR}/${ARG_TARGET}ConfigVersion.cmake"
        VERSION ${PROJECT_VERSION}
        COMPATIBILITY SameMajorVersion
    )

    # Exports the target for usage by find_package()
    install(EXPORT ${ARG_TARGET}Targets
        FILE ${ARG_TARGET}Targets.cmake
        NAMESPACE ${ARG_TARGET}:: # Enables: target_link_libraries(myapp PRIVATE ${ARG_TARGET}::Lib)
        DESTINATION ${CONFIG_INSTALL_DIR}
    )

    # Converts list of dependencies to space-separated for @PACKAGE_DEPENDENCIES@
    string(REPLACE ";" " " PACKAGE_DEPENDENCIES "${ARG_DEPENDENCIES}")

    # Configures the generic config template
    configure_file(
        ${PROJECT_SOURCE_DIR}/cmake/GenericConfig.cmake.in
        ${CMAKE_CURRENT_BINARY_DIR}/${ARG_TARGET}Config.cmake
        @ONLY
    )

    # Installs the configured package config files
    install(FILES
        "${CMAKE_CURRENT_BINARY_DIR}/${ARG_TARGET}Config.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/${ARG_TARGET}ConfigVersion.cmake"
        DESTINATION ${CONFIG_INSTALL_DIR}
    )
endfunction()


# ========================
# install_static_library
# ========================
# Installs a static (.a/.lib) library and its CMake package files for use with find_package().
#
# Usage:
#   install_static_library(
#       TARGET        <target_name>           # Required: Name of the static library target to install
#       DEPENDENCIES  <dep1> <dep2> ...       # Optional: List of other packages this target depends on
#   )
#
# Example:
#   install_static_library(
#       TARGET mylib
#       DEPENDENCIES anotherlib thirdlib
#   )
#
# What it does:
# - Installs the static library to ${CMAKE_INSTALL_LIBDIR}
# - Exports CMake package config + version files to enable find_package(mylib)
# - Includes headers from the `include/` directory
# - Registers target dependencies in the generated config
function(install_static_library)
    # Parses arguments
    set(options)
    set(oneValueArgs TARGET)
    set(multiValueArgs DEPENDENCIES)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT ARG_TARGET)
        message(FATAL_ERROR ">>>>> install_static_library: TARGET is required.")
    endif()

    install(TARGETS ${ARG_TARGET}
        EXPORT ${ARG_TARGET}Targets
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )

    install_library_requirements(
        TARGET ${ARG_TARGET}
        DEPENDENCIES ${ARG_DEPENDENCIES}
        TYPE STATIC
    )
endfunction()


# ========================
# install_shared_library
# ========================
# Installs a shared (.so/.dll) library and its CMake package files for use with find_package().
#
# Usage:
#   install_shared_library(
#       TARGET        <target_name>           # Required: Name of the shared library target to install
#       DEPENDENCIES  <dep1> <dep2> ...       # Optional: List of other packages this target depends on
#   )
#
# Example:
#   install_shared_library(
#       TARGET mysharedlib
#       DEPENDENCIES corelib utils
#   )
#
# What it does:
# - Installs the shared library (.dll/.so/.dylib) to ${CMAKE_INSTALL_LIBDIR}
# - Installs the target's runtime (executable or DLL) to ${CMAKE_INSTALL_BINDIR}
# - Installs headers from the `include/` directory to ${CMAKE_INSTALL_INCLUDEDIR}
# - Exports CMake config + version files for find_package() support
# - Registers dependencies so downstream projects can automatically find them
function(install_shared_library)
    # Parses arguments
    set(options)
    set(oneValueArgs TARGET)
    set(multiValueArgs DEPENDENCIES)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT ARG_TARGET)
        message(FATAL_ERROR ">>>>> install_shared_library: TARGET is required.")
    endif()

    install(TARGETS ${ARG_TARGET}
        EXPORT ${ARG_TARGET}Targets
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )

    install_library_requirements(
        TARGET ${ARG_TARGET}
        DEPENDENCIES ${ARG_DEPENDENCIES}
        TYPE SHARED
    )
endfunction()


# ================================
# install_interface_library
# ================================
# Installs a header-only (INTERFACE) library and its CMake package files.
#
# Usage:
#   install_interface_library(
#       TARGET        <target_name>           # Required: Name of the INTERFACE library target
#       DEPENDENCIES  <dep1> <dep2> ...       # Optional: List of dependent packages
#   )
#
# Example:
#   install_interface_library(
#       TARGET myheaders
#       DEPENDENCIES platform_types
#   )
#
# What it does:
# - Installs the INTERFACE target for use with find_package()
# - Installs headers from the `include/` directory to ${CMAKE_INSTALL_INCLUDEDIR}
# - Exports a CMake config and version file
# - Includes `find_dependency()` entries for any listed dependencies
#
# Note:
# - INTERFACE targets do not produce binaries; only header + config installation is needed.
function(install_interface_library)
    # Parses arguments
    set(options)
    set(oneValueArgs TARGET)
    set(multiValueArgs DEPENDENCIES)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT ARG_TARGET)
        message(FATAL_ERROR ">>>>> install_interface_library: TARGET is required.")
    endif()

    install(TARGETS ${ARG_TARGET}
        EXPORT ${ARG_TARGET}Targets
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )

    install_library_requirements(
        TARGET ${ARG_TARGET}
        DEPENDENCIES ${ARG_DEPENDENCIES}
        TYPE INTERFACE
    )
endfunction()


# ============================
# install_module_library
# ============================
# Installs a module-style shared library (plugin) directly to the runtime folder.
#
# Usage:
#   install_module_library(
#       TARGET <target_name>                 # Required: Name of the module (shared) library target
#   )
#
# Example:
#   install_module_library(
#       TARGET myplugin
#   )
#
# What it does:
# - Installs the target's shared library (e.g. plugin .dll/.so) to ${CMAKE_INSTALL_BINDIR}
# - No config, headers, or dependency registration
#
# Notes:
# - This is intended for plugin-style libraries that are not meant to be linked directly
# - If you need find_package() support, use install_shared_library() instead
function(install_module_library)
    # Parses arguments
    set(options)
    set(oneValueArgs TARGET)
    set(multiValueArgs)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT ARG_TARGET)
        message(FATAL_ERROR ">>>>> install_module_library: TARGET is required.")
    endif()

    install(TARGETS ${ARG_TARGET}
        EXPORT ${ARG_TARGET}Targets
        LIBRARY DESTINATION ${CMAKE_INSTALL_BINDIR} # for .dll/.so plugins
    )
endfunction()


# ================================
# install_test_executable
# ================================
# Installs a test executable along with optional runtime data and a generated .bat launcher.
#
# Usage:
#   install_test_executable(
#       TARGET      <test_target_name>       # Required: Target to install
#       DIRECTORIES <dir1> <dir2> ...        # Optional: Resource/data dirs to copy alongside the test
#   )
#
# Example:
#   install_test_executable(
#       TARGET ui_test_runner
#       DIRECTORIES data resource shaders
#   )
#
# What it does:
# - Installs the test executable to: ${CMAKE_INSTALL_PREFIX}/tests/<TARGET>
# - Copies any specified resource directories into the test install folder
# - Generates a `TARGET.bat` launcher from a template (`runtest.bat.in`) and installs it
#
# Notes:
# - DIRECTORIES can be absolute or relative (relative paths are resolved from current source dir)
# - Directories are placed inside the test install folder: tests/<TARGET>/<dir_name>
# - Warns if any listed directories do not exist
function(install_test_executable)
    # Parses arguments
    set(options)
    set(oneValueArgs TARGET)
    set(multiValueArgs DIRECTORIES)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT ARG_TARGET)
        message(FATAL_ERROR ">>>>> install_test_executable: TARGET argument is required.")
    endif()

    # Installs the test executable into its own subdirectory
    install(TARGETS ${ARG_TARGET}
        RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/tests/${ARG_TARGET}
    )

    # Generates the runtime .bat script from template
    configure_file(
        "${PROJECT_SOURCE_DIR}/cmake/runtest.bat.in"
        "${CMAKE_CURRENT_BINARY_DIR}/${ARG_TARGET}.bat"
        @ONLY
    )

    # Generates the runtime .bat script from template
    install(FILES
        "${CMAKE_CURRENT_BINARY_DIR}/${ARG_TARGET}.bat"
        DESTINATION ${CMAKE_INSTALL_PREFIX}/tests/${ARG_TARGET}
    )

    # Generates each extra directory into the test folder (if it exists)
    foreach(dir IN LISTS ARG_DIRECTORIES)
        if(NOT IS_ABSOLUTE "${dir}")
            # Converts relative paths to absolute paths based on the source directory
            set(dir "${CMAKE_CURRENT_SOURCE_DIR}/${dir}")
        endif()

        if(EXISTS "${dir}")
            get_filename_component(dir_name "${dir}" NAME)
            install(DIRECTORY "${dir}/"
                DESTINATION ${CMAKE_INSTALL_PREFIX}/tests/${ARG_TARGET}/${dir_name}
            )
        else()
            message(WARNING ">>>> Directory '${dir}' does not exist in ${CMAKE_CURRENT_SOURCE_DIR}")
        endif()
    endforeach()
endfunction()
