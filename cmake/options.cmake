# Build options definition file

option(BUILD_TESTS          "Enable extra test builds."                 OFF )
option(BUILD_SHARED_LIBS    "Enable build for dynamic-link library."    OFF )

if(NOT CMAKE_BUILD_TYPE)
    # try detect CMAKE_BUILD_TYPE from build dir name
    get_filename_component(__BUILD_NAME_DIR ${CMAKE_BINARY_DIR} NAME)
    string(TOLOWER ${__BUILD_NAME_DIR} __BUILD_NAME_DIR)

    if(__BUILD_NAME_DIR MATCHES "^debug$")
        message(STATUS "Detected CMAKE_BUILD_TYPE=Debug from build dir")
        set(
            CMAKE_BUILD_TYPE Debug CACHE STRING
            "Type of build [None Debug Release RelWithDebInfo MinSizeRel]."
            FORCE
        )
    else()
        set(
            CMAKE_BUILD_TYPE Release CACHE STRING
            "Type of build [None Debug Release RelWithDebInfo MinSizeRel]."
            FORCE
        )
    endif()
endif()
