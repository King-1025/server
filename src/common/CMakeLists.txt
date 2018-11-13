add_custom_command(OUTPUT base64u.c
	           COMMAND echo "/*No use in editing, auto create!*/" > base64u.c
		   #		   COMMAND sed -e "s/\\([Bb][Aa][Ss][Ee]64\)/\\1u/g ; s/0123456789+/0123456789_/" base64.c >> base64u.c
		   COMMENT "create base64u.c"
		   )
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
add_library (common SHARED  ${COMMON_SRC})
