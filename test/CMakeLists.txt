if(${BUILD_TESTS})
    file(GLOB tests_src "*.c")
    foreach(test_path ${tests_src})
        get_filename_component(srcname ${test_path} NAME)
        get_filename_component(execname ${test_path} NAME_WE)
        add_executable(${execname} ${srcname})

        target_include_directories(
            ${execname}
                PRIVATE
                    ${PROJECT_SOURCE_DIR}/include
        )

        target_link_libraries(${execname} PRIVATE ${PROJECT_NAME})

        set_target_properties(
            ${execname} PROPERTIES
                BINARY_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/bin"
        )

    endforeach()
endif()
