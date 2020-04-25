add_library(
    ${PROJECT_NAME}
        serialport.c
        timing.c
        $<TARGET_OBJECTS:${PROJECT_NAME}_sysdeps>
)

string(REPLACE ":" "." SOVERSION_STR ${PROJECT_SOVERSION})
set_target_properties(
    ${PROJECT_NAME} PROPERTIES
        SOVERSION ${SOVERSION_STR}
)

# Build option
target_compile_features(
    ${PROJECT_NAME} PRIVATE
        c_std_99
)

target_compile_definitions(
    ${PROJECT_NAME} PRIVATE
        -D_GNU_SOURCE
)

target_compile_options(
    ${PROJECT_NAME} PRIVATE
        -Wall -Wextra -Werror -Wshadow
        -Wno-unused-parameter -Wmissing-prototypes
        -pedantic -ffunction-sections -fdata-sections
)

target_include_directories(
    ${PROJECT_NAME}
        PUBLIC
            ${PROJECT_SOURCE_DIR}/include
        PRIVATE
            # ${PROJECT_SOURCE_DIR}/lib/
            ${CMAKE_CURRENT_SOURCE_DIR}
            # ${CMAKE_CURRENT_SOURCE_DIR}/sysdeps
)

# target_link_libraries(
#     ${PROJECT_NAME}
#     PRIVATE
#         lib*
# )
# -version-info $(SP_LIB_VERSION) -no-undefined
add_subdirectory(sysdeps)
