#服务器
aux_source_directory (. DIR_SRCS)
add_executable (iodined ${DIR_SRCS})
target_link_libraries (iodined common)
#安装目标到最终路径
install (TARGETS iodined RUNTIME DESTINATION bin)
