#客户端
aux_source_directory (. DIR_SRCS)
add_executable (iodine ${DIR_SRCS})
target_link_libraries (iodine common)
#安装目标到最终路径
install (TARGETS iodine RUNTIME DESTINATION bin)
