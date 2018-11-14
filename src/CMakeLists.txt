message(STATUS "OS:${CMAKE_SYSTEM_NAME}")

#set(CMAKE_SYSTEM_NAME "windows32")

execute_process(COMMAND sh ${CMAKE_CURRENT_SOURCE_DIR}/osflags ${CMAKE_SYSTEM_NAME} link
	        OUTPUT_VARIABLE OS_LDFLAGS)
execute_process(COMMAND sh ${CMAKE_CURRENT_SOURCE_DIR}/osflags ${CMAKE_SYSTEM_NAME} cflags
	        OUTPUT_VARIABLE OS_CFLAGS)
execute_process(COMMAND sh ${CMAKE_CURRENT_SOURCE_DIR}/tr ${CMAKE_SYSTEM_NAME} 
        	OUTPUT_VARIABLE SYSTEM_NAME)
execute_process(COMMAND sh ${CMAKE_CURRENT_SOURCE_DIR}/revision
	        OUTPUT_VARIABLE GIT_REVISION)

set(LDFLAGS "-lz ${OS_LDFLAGS} -L.")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OS_CFLAGS} -std=c99 -c -g -Wall -pedantic -Wstrict-prototypes -Wtype-limits -Wmissing-declarations -Wmissing-prototypes")

add_definitions(-D${SYSTEM_NAME} -DGITREVISION="${GIT_REVISION}")

set(CMAKE_STATIC_LINKER_FLAGS ${LDFLAGS})
add_subdirectory (common)
add_subdirectory (server)
#add_subdirectory (client)
