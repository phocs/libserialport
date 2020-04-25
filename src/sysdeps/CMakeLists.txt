# Linux             Linux
# Cygwin            Cygwin
# Windows           Windows
# MacOSX            Darwin* -> ck CMAKE_HOST_APPLE

if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    if(${CMAKE_HOST_APPLE})
        set(CMAKE_SYSTEM_NAME "macOS")
    endif()
endif()

message("-- Build for \'${CMAKE_SYSTEM_NAME}\' operating system.")

if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
    add_subdirectory(linux)
elseif(${CMAKE_SYSTEM_NAME} MATCHES "macOS")
    add_subdirectory(macos)
endif()

target_include_directories(
    ${PROJECT_NAME}_sysdeps PRIVATE
        ${CMAKE_SOURCE_DIR}/include
        ${CMAKE_SOURCE_DIR}/src
)
