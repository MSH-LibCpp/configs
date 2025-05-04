# ============================================
# copy_directory_after_build
# ============================================
# Adds POST_BUILD commands to copy:
#   - an entire source directory
#   - OR specific files from that directory
# to a destination folder after a given target is built.
#
# Usage:
#   copy_directory_after_build(
#       TARGET      <TargetName>           # Required: the target to attach copy commands to
#       SOURCE      <SourceDirectory>      # Required: directory to copy from
#       DESTINATION <DestinationDirectory> # Required: where to copy to
#       FILES       <file1> <file2> ...    # Optional: list of specific files inside SOURCE to copy
#   )
#
# Notes:
# - FILES are relative to SOURCE.
# - If FILES is not provided, the entire directory is copied.
# - Uses `copy_if_different` for per-file copy, or `copy_directory` for full copy.
function(copy_directory_after_build)
    # Parses arguments
    set(options)
    set(oneValueArgs TARGET SOURCE DESTINATION)
    set(multiValueArgs FILES)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Ensures required arguments are provided
    if(NOT ARG_TARGET OR NOT ARG_SOURCE OR NOT ARG_DESTINATION)
        message(FATAL_ERROR ">>>>> copy_directory_after_build: TARGET, SOURCE, and DESTINATION are required.")
    endif()

    if(ARG_FILES)
        # Copies each file individually using copy_if_different
        foreach(file IN LISTS ARG_FILES)
            add_custom_command(TARGET ${ARG_TARGET} POST_BUILD
                COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "${ARG_SOURCE}/${file}"
                "${ARG_DESTINATION}/${file}"
                COMMENT "Copying file ${file} from ${ARG_SOURCE} to ${ARG_DESTINATION}"
                VERBATIM
            )
        endforeach()
    else()
        # Copies the entire directory using copy_directory
        add_custom_command(TARGET ${ARG_TARGET} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_directory
            "${ARG_SOURCE}"
            "${ARG_DESTINATION}"
            COMMENT "Copying directory ${ARG_SOURCE} to ${ARG_DESTINATION}"
            VERBATIM
        )
    endif()
endfunction()

# ============================================
# copy_files_after_build
# ============================================
# Adds POST_BUILD copy commands to copy multiple files to a target directory.
#
# Supports:
# - Generator expressions like $<TARGET_FILE:MyLib>
# - Literal file paths
#
# Usage:
#   copy_files_after_build(
#       TARGET      <TargetToAttachCommand>     # Required
#       FILES       <file1> <file2> ...         # Required
#       DESTINATION <DestinationDirectory>      # Required
#   )
#
# Example:
#   copy_files_after_build(
#       TARGET MyApp
#       FILES
#           $<TARGET_FILE:mynamespace::mylib>
#           "${CMAKE_CURRENT_SOURCE_DIR}/static/config.json"
#       DESTINATION "${CMAKE_BINARY_DIR}/copied"
#   )
function(copy_files_after_build)
    # Parses arguments
    set(options)
    set(oneValueArgs TARGET DESTINATION)
    set(multiValueArgs FILES)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Validates required arguments
    if(NOT ARG_TARGET OR NOT ARG_FILES OR NOT ARG_DESTINATION)
        message(FATAL_ERROR ">>>>> copy_files_after_build: TARGET, FILES, and DESTINATION are required.")
    endif()

    # Begins a list of post-build commands
    set(commands "")
    list(APPEND commands
        COMMAND ${CMAKE_COMMAND} -E make_directory "${ARG_DESTINATION}"
    )

    # Copies each file individually
    foreach(file IN LISTS ARG_FILES)
        # If `file` is a generator expression like $<TARGET_FILE:...>,
        # we use $<TARGET_FILE_NAME:...> to extract the filename at build time.
        # Otherwise, it falls back to using the filename from the input directly.
        list(APPEND commands
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${file}"
            "${ARG_DESTINATION}/$<IF:$<BOOL:$<TARGET_FILE_NAME:${file}>>,$<TARGET_FILE_NAME:${file}>,${file}>"
        )
    endforeach()

    # Attaches post-build copy commands to the target
    add_custom_command(TARGET ${ARG_TARGET} POST_BUILD
        ${commands}
        COMMENT "Copying files to ${ARG_DESTINATION}"
        VERBATIM
    )
endfunction()
