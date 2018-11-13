#客户端
aux_source_directory (client CLIENT_SRCS)
add_executable (iodine ${CLIENT_SRCS})
target_link_libraries (iodine common)
#服务器
aux_source_directory (server SERVER_SRCS)
add_executable (iodined ${SERVER_SRCS})
target_link_libraries (iodined common)
#安装目标到最终路径
install (TARGETS iodine iodined RUNTIME DESTINATION bin)
#添加子目录
add_subdirectory (common)
#add_subdirectory (client)
#add_subdirectory (server)
