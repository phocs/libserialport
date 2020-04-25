include(CheckIncludeFiles)
include(CheckSymbolExists)
include(CheckFunctionExists)
include(CheckCSourceCompiles)

function(setnot var value)
    if(${value})
        set(${var} false PARENT_SCOPE)
    else()
        set(${var} true  PARENT_SCOPE)
    endif()
endfunction()

function(message_check_status str res)
    if(${res})
        message(STATUS "Checking " "${str}" "success")
    else()
        message(STATUS "Checking " "${str}" "fail")
    endif()
endfunction()

function(check_include header var)
    unset(__res CACHE)
    set(CMAKE_REQUIRED_QUIET ON)
    check_include_files(${header} __res)
    set(${var} ${__res} PARENT_SCOPE)
    message_check_status("for ${header}... " __res)
endfunction()

function(check_type type header var)
    unset(__res CACHE)
    set(CMAKE_REQUIRED_QUIET ON)
    check_c_source_compiles(
        "
        #include <${header}>
        void foo(${type} test);
        int main(void) {return 0;}
        "
        __res
    )
    set(${var} ${__res} PARENT_SCOPE)
    message_check_status("for ${type}... " __res)
endfunction()

function(check_type_member type member header var)
    unset(__res CACHE)
    set(CMAKE_REQUIRED_QUIET ON)
    check_c_source_compiles(
        "
        #include <${header}>
        int main(void) {((${type} *)0)->${member}; return 0; }
        "
        __res
    )
    set(${var} ${__res} PARENT_SCOPE)
    message_check_status("for ${type}.${member}... " __res)
endfunction()

function(check_attribute attr var)
    unset(__res CACHE)
    unset(__flags_tmp CACHE)
    set(CMAKE_REQUIRED_QUIET ON)
    set(__flags_tmp ${CMAKE_REQUIRED_FLAGS})
    if(MSVC)
        set(CMAKE_REQUIRED_FLAGS "-WX")
    else()
        set(CMAKE_REQUIRED_FLAGS "-Werror")
    endif()
    check_c_source_compiles(
        "
        ${attr} void foo(void) {}
        int main(void) {return 0;}
        "
        __res
    )
    set(${var} ${__res} PARENT_SCOPE)
    set(CMAKE_REQUIRED_FLAGS ${__flags_tmp})
    message_check_status("for ${attr}... " __res)
endfunction()

function(check_define def header var)
    unset(__res CACHE)
    set(CMAKE_REQUIRED_QUIET ON)
    check_symbol_exists(${def} ${header} __res)
    set(${var} ${__res} PARENT_SCOPE)
    message_check_status("for ${def}... " __res)
endfunction()

function(check_function fun var)
    unset(__res CACHE)
    set(CMAKE_REQUIRED_QUIET ON)
    check_function_exists(${fun} __res)
    set(${var} ${__res} PARENT_SCOPE)
    message_check_status("for ${fun}()... " __res)
endfunction()

function(check_largefile_support var)
    unset(__res CACHE)
    set(CMAKE_REQUIRED_QUIET ON)
    if(CMAKE_C_COMPILER_ID MATCHES "MSVC")
        # This is Visual Studio; Visual Studio has LFS
        # since Visual Studio 2005 / MSVCR80,
        # and we require newer versions, so we know we have them.
        set(__res true)
    else()
        # This is UN*X, or some other Windows compiler.
        #
        # For UN*X, we do the Large File Support tests, to see
        # whether it's present and, if so what we need to define
        # to enable it.
        #
        # On most platforms it is probably overkill to first test
        # the flags for 64-bit off_t, and then separately fseeko.
        # However, in the future we might have 128-bit seek offsets
        # to support 128-bit filesystems that allow 128-bit offsets
        # (ZFS), so it might be dangerous to indiscriminately set
        # e.g. _FILE_OFFSET_BITS=64.
        try_compile(
            __test
            "${CMAKE_CURRENT_BINARY_DIR}/ConfigTmp"
            "${CMAKE_SOURCE_DIR}/cmake/lfs/test_file_offset.c"
        )

        if(NOT __test)
            try_compile(
                __test
                "${CMAKE_CURRENT_BINARY_DIR}/ConfigTmp"
                "${CMAKE_SOURCE_DIR}/cmake/lfs/test_file_offset.c"
                COMPILE_DEFINITIONS "-D_FILE_OFFSET_BITS=64"
            )
            if(__test)
                set(_FILE_OFFSET_BITS 64 CACHE INTERNAL "64-bit off_t requires _FILE_OFFSET_BITS=64" PARENT_SCOPE)
            endif()
        endif()

        if(NOT __test)
            try_compile(
                __test
                "${CMAKE_CURRENT_BINARY_DIR}/ConfigTmp"
                "${CMAKE_SOURCE_DIR}/cmake/lfs/test_file_offset.c"
                COMPILE_DEFINITIONS "-D_LARGE_FILES"
            )
            if(__test)
                set(_LARGE_FILES 1 CACHE INTERNAL "64-bit off_t requires _LARGE_FILES" PARENT_SCOPE)
            endif()
        endif()

        if(NOT __test)
            try_compile(
                __test
                "${CMAKE_CURRENT_BINARY_DIR}/ConfigTmp"
                "${CMAKE_SOURCE_DIR}/cmake/lfs/test_file_offset.c"
                COMPILE_DEFINITIONS "-D_LARGEFILE_SOURCE"
            )
            if(__test)
                set(_LARGEFILE_SOURCE 1 CACHE INTERNAL "64-bit off_t requires _LARGEFILE_SOURCE" PARENT_SCOPE)
            endif()
        endif()

        if(NOT __test)
            set(__res false)
        elseif(NOT WIN32) # If this is UN*X, check for fseeko/ftello.
            configure_file(
                "${CMAKE_SOURCE_DIR}/cmake/lfs/test_largefiles.c.in"
                "${CMAKE_CURRENT_BINARY_DIR}/ConfigTmp/test_largefiles.c"
            )

            try_compile(
                __test "${CMAKE_CURRENT_BINARY_DIR}/ConfigTmp"
                "${CMAKE_CURRENT_BINARY_DIR}/ConfigTmp/test_largefiles.c"
            )

            if(NOT __test)
                # glibc 2.2 neds _LARGEFILE_SOURCE for fseeko (but not 64-bit off_t...)
                try_compile(
                    __test "${CMAKE_CURRENT_BINARY_DIR}/ConfigTmp"
                    "${CMAKE_CURRENT_BINARY_DIR}/ConfigTmp/test_largefiles.c"
                    COMPILE_DEFINITIONS "-D_LARGEFILE_SOURCE"
                )

                if(__test)
                    set(_LARGEFILE_SOURCE 1 CACHE INTERNAL "64-bit fseeko requires _LARGEFILE_SOURCE")
                endif()
            endif()

            if(__test)
                set(__res true)
            else()
                set(__res false)
            endif()
        endif()
    endif()
    set(${var} ${__res} PARENT_SCOPE)
    message_check_status("for large files support... " __res)
endfunction()

# Library Version for libserialport (NOT the same as the Package Version).
# - Start with version information of ‘0:0:0’.
# - If the library source code has changed at all since the last update,
#   then increment revision (‘c:r:a’ becomes ‘c:r+1:a’).
# - If any interfaces have been added, removed, or changed
#   since the last update, increment current, and set revision to 0.
# - If any interfaces have been added since the last public release,
#   then increment age.
# - If any interfaces have been removed or changed since the last
#   public release, then set age to 0.
set(PROJECT_SOVERSION_CURRENT   1)
set(PROJECT_SOVERSION_REVISION  0)
set(PROJECT_SOVERSION_AGE       1)
set(PROJECT_SOVERSION
    "${PROJECT_SOVERSION_CURRENT}:${PROJECT_SOVERSION_REVISION}:${PROJECT_SOVERSION_AGE}"
)

# Configuration: NO_ENUMERATION, NO_PORT_METADATA
if(NOT ${CMAKE_SYSTEM_NAME} MATCHES "Linux*|Darwin*|Windows*|FreeBSD*")
    set(NO_ENUMERATION 1)
    set(NO_PORT_METADATA 1)
endif()

# Large file support
check_largefile_support(HAVE_LFS)
# message(STATUS "_LARGE_FILES \'${_LARGE_FILES}\'")
# message(STATUS "_LARGEFILE_SOURCE \'${_LARGEFILE_SOURCE}\'")
# message(STATUS "_FILE_OFFSET_BITS \'${_FILE_OFFSET_BITS}\'")

check_include("dlfcn.h"       HAVE_DLFCN_H     )
check_include("inttypes.h"    HAVE_INTTYPES_H  )
check_include("memory.h"      HAVE_MEMORY_H    )
check_include("stdint.h"      HAVE_STDINT_H    )
check_include("stdlib.h"      HAVE_STDLIB_H    )
check_include("strings.h"     HAVE_STRINGS_H   )
check_include("string.h"      HAVE_STRING_H    )
check_include("sys/stat.h"    HAVE_SYS_STAT_H  )
check_include("sys/types.h"   HAVE_SYS_TYPES_H )
check_include("sys/file.h"    HAVE_SYS_FILE_H  )
check_include("unistd.h"      HAVE_UNISTD_H    )
check_include("stddef.h"      HAVE_STDDEF_H    )

check_type(
    "size_t" "sys/types.h" HAVE_SIZE_T
)
setnot(size_t ${HAVE_SIZE_T})

check_type(
    "struct termiox" "linux/termios.h" HAVE_STRUCT_TERMIOX
)

check_type(
    "struct termios2" "linux/termios.h" HAVE_STRUCT_TERMIOS2
)

check_type(
    "struct serial_struct" "linux/serial.h" HAVE_STRUCT_SERIAL_STRUCT
)

check_type_member(
    "struct termios" "c_ispeed" "linux/termios.h" HAVE_STRUCT_TERMIOS_C_ISPEED
)

check_type_member(
    "struct termios" "c_ospeed" "linux/termios.h" HAVE_STRUCT_TERMIOS_C_OSPEED
)

check_type_member(
    "struct termios2" "c_ispeed" "linux/termios.h" HAVE_STRUCT_TERMIOS2_C_ISPEED
)

check_type_member(
    "struct termios2" "c_ospeed" "linux/termios.h" HAVE_STRUCT_TERMIOS2_C_OSPEED
)

check_define(
    "BOTHER" "linux/termios.h" HAVE_DECL_BOTHER
)

check_function(
    "realpath" HAVE_REALPATH
)

check_function(
    "clock_gettime" HAVE_CLOCK_GETTIME
)

check_function(
    "flock" HAVE_FLOCK
)

check_attribute(
    "__declspec(dllexport)" HAVE_DDLEXPORT
)

check_attribute(
    "__attribute__((visibility(\"hidden\")))" HAVE_VISIBILITY_ATTR
)

if(${HAVE_VISIBILITY_ATTR})
    set(SP_API "__attribute__((visibility(\"default\")))")
    set(SP_PRIV "__attribute__((visibility(\"hidden\")))")
elseif(HAVE_DDLEXPORT AND ${BUILD_SHARED_LIBS})
    set(SP_API "__declspec(dllexport)")
endif()

configure_file(
    ${CMAKE_SOURCE_DIR}/cmake/config.h.in
    ${CMAKE_SOURCE_DIR}/src/config.h
    @ONLY
)
