add_library(${PROJECT_NAME}_sysdeps OBJECT macosx.c)

find_library(LIB_IOKIT IOKit)
find_library(LIB_COREFOUNDATION CoreFoundation)

target_link_libraries(
    ${PROJECT_NAME}_sysdeps
    ${LIB_IOKIT} ${LIB_COREFOUNDATION}
)

if(${BUILD_SHARED_LIBS})
    target_link_libraries(
        ${PROJECT_NAME}
        ${LIB_IOKIT} ${LIB_COREFOUNDATION}
    )
endif()
