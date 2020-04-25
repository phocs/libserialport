cmake_minimum_required(VERSION 3.16 FATAL_ERROR)

# Disable in-source builds to prevent source tree corruption.
if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
    message(FATAL_ERROR "FATAL: In-source builds are not allowed.
    You should create a separate directory for build files.")
endif()

# Package Version
# - If breaking API compatibility in a library, or making a large change to an
#   application which affects everything (such as a UI redesign), increment
#   major and set minor and micro to 0.
# - Otherwise, if changing or adding a feature, or adding any API,
#   increment minor and set micro to 0.
# - Otherwise (if making a release containing only bug fixes and translation
#   updates), increment micro.

project(
    serialport
	VERSION 0.2.0
    LANGUAGES C
    DESCRIPTION "Unofficial repository for libserialport."
    HOMEPAGE_URL "https://github.com/phocs/serialport.git"
)

#Make sure that custom modules are found
list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
include(config)
include(options)

# add_subdirectory(lib)
add_subdirectory(src)
# add_subdirectory(examples)
# add_subdirectory(test)
# add_subdirectory(man)
# add_subdirectory(docs)

# Target install
include(GNUInstallDirs)

set_target_properties(
    ${PROJECT_NAME} PROPERTIES
        PUBLIC_HEADER ${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}.h
)

install(
    TARGETS ${PROJECT_NAME}
        LIBRARY         DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE         DESTINATION ${CMAKE_INSTALL_LIBDIR}
        PUBLIC_HEADER   DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

if (UNIX)
    set(PROJECT_PC_REQUIRES_PRIVATE formatter)
    set(PROJECT_PC_LIBS_PRIVATE -lformatter)

    configure_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/cmake/${PROJECT_NAME}.pc.in
        ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.pc
        @ONLY
    )

    install(
        FILES ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.pc
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
    )
endif()

if(NOT TARGET uninstall)
    configure_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/cmake/uninstall.cmake.in
        ${CMAKE_CURRENT_BINARY_DIR}/uninstall.cmake
        IMMEDIATE @ONLY
    )

    add_custom_target(
        uninstall
        COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/uninstall.cmake
    )
endif()

#
# message(STATUS "Package version................. $SP_PACKAGE_VERSION")
# message(STATUS "Library ABI version............. $SP_LIB_VERSION")
# message(STATUS "Prefix.......................... $prefix")
# message(STATUS "Building on..................... $build")
# message(STATUS "Building for.................... $host")
# message(STATUS "Building shared/static.......... $enable_shared / $enable_static")
# message(STATUS "Package version................. $SP_PACKAGE_VERSION")
# message(STATUS "Package version................. $SP_PACKAGE_VERSION")
#
# message(STATUS "Compile configuration:")
# message(STATUS "C compiler...................... $CC")
# message(STATUS "C compiler version.............. $sp_cc_version")
# message(STATUS "C compiler flags................ $CFLAGS")
# message(STATUS "Linker flags.................... $LDFLAGS")
