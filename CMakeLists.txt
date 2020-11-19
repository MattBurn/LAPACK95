cmake_minimum_required(VERSION 3.13)  # 3.13 target_sources absolute
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Debug or Release")
endif()
get_directory_property(is-subproject PARENT_DIRECTORY)
project(LAPACK95 C Fortran)
enable_testing()

include(cmake/compilers.cmake)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Modules)

set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include)

set(BUILD_SHARED_LIBS OFF)
add_subdirectory("subprojects/lapack")
list(
  APPEND lib-deps
  "lapack-lib"
)

if(NOT arith)
  # only one precision at a time
  set(arith "d")
endif()

add_library(lapack95)
add_subdirectory(src)
target_include_directories(lapack95 PUBLIC ${CMAKE_Fortran_MODULE_DIRECTORY})
target_compile_options(lapack95 PRIVATE ${FFLAGS})
set_target_properties(lapack95 PROPERTIES
  ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
add_library(lib-deps ALIAS lapack95)

set_target_properties(
  "lapack95-lib"
  PROPERTIES
  POSITION_INDEPENDENT_CODE TRUE
  OUTPUT_NAME "${PROJECT_NAME}"
  VERSION "${PROJECT_VERSION}"
  SOVERSION "${PROJECT_VERSION_MAJOR}"
  Fortran_MODULE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/include"
)
target_include_directories(
  "lapack95-lib"
  INTERFACE
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

if(NOT is-subproject OR BUILD_SHARED_LIBS)
  add_executable(gbsv ${CMAKE_CURRENT_SOURCE_DIR}/EXAMPLES1/la_gbsv_example.f90)
  # target_link_libraries(gbsv PRIVATE LAPACK::LAPACK95 LAPACK::LAPACK)
  target_link_libraries(gbsv lib-deps)
  add_test(NAME GBSV COMMAND $<TARGET_FILE:gbsv> ${CMAKE_CURRENT_SOURCE_DIR}/EXAMPLES1)
  
  # Install
  
  install(TARGETS lapack95
          LIBRARY DESTINATION lib
          ARCHIVE DESTINATION lib)
  
  install(DIRECTORY ${CMAKE_Fortran_MODULE_DIRECTORY}/ # don't omit trailing slash
          DESTINATION include)
endif()
