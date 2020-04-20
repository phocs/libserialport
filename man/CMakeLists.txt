if (UNIX)

    include(GNUInstallDirs)
    find_program(ronn_FOUND ronn)

    if (NOT ronn_FOUND)
        message(WARNING "Cannot update man pages - ronn command not found! -")
        file(GLOB MAN_PAGES ${CMAKE_CURRENT_SOURCE_DIR}/*.[1-8])
        foreach(MAN_PATH IN LISTS MAN_PAGES)
            string(REGEX REPLACE ".*\\." "" MAN_CHAPTER ${MAN_PATH})
            install(FILES ${MAN_PATH} DESTINATION ${CMAKE_INSTALL_MANDIR}/man${MAN_CHAPTER})
        endforeach(MAN_PATH)
    else()
    	file(GLOB RONN_PAGES ${CMAKE_CURRENT_SOURCE_DIR}/*.[1-8].ronn)
    	foreach(RONN_PATH IN LISTS RONN_PAGES)
    		get_filename_component(RONNPAGE ${RONN_PATH} NAME)
    		string(REGEX REPLACE "\.ronn$" "" MANPAGE ${RONNPAGE})
            string(REGEX REPLACE ".*\\." "" MAN_CHAPTER ${MANPAGE})

            add_custom_target(
                man_page_${MANPAGE} ALL
                make ${MANPAGE}
            	   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            )

            install(
                FILES ${CMAKE_CURRENT_SOURCE_DIR}/${MANPAGE}
                    DESTINATION ${CMAKE_INSTALL_MANDIR}/man${MAN_CHAPTER}
            )
    	endforeach(RONN_PATH)
    endif()

endif()
