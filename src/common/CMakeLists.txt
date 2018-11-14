execute_process(COMMAND sh "${CMAKE_CURRENT_SOURCE_DIR}/base64u" base64.c)
set(COMMON_SRC tun.c
	       dns.c 
	       read.c 
	       encoding.c 
	       login.c
	       base32.c
	       base64.c
	       base64u.c
	       base128.c
	       md5.c
	       common.c)
message(STATUS ${CMAKE_C_FLAGS})
add_library (common  ${COMMON_SRC})
