cmake_minimum_required(VERSION 2.8.8 FATAL_ERROR)
cmake_policy(VERSION 2.8.8)

list(APPEND my_include_dirs
  "${CMAKE_CURRENT_LIST_DIR}"
  "${CMAKE_CURRENT_LIST_DIR}/.."
  ${LUA51_INCLUDE_DIRS}
  )



##################################################################################################
#yxkite\yxkite.gyp:yxkite#target
set(my_target "hello")
set(TARGET ${my_target})
set(TOOLSET "target")

list(APPEND my_srcs
    demo/main.cpp
    demo/lsocket.c
  )
add_executable(${my_target} ${my_srcs})
set_property(TARGET ${my_target} APPEND PROPERTY INCLUDE_DIRECTORIES ${my_include_dirs})
set_target_properties(${my_target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)
SET_COMMON_TARGET_PROPERTIES(${my_target})

target_link_libraries(${my_target}
  ${LUA51_LIBRARIES}
  ws2_32
)

unset(TOOLSET)
unset(TARGET)
unset(my_srcs)
unset(my_target)




