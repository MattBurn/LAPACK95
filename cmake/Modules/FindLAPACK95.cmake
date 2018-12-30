# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#[=======================================================================[.rst:
FindLAPACK95
------------

Finds the LAPACK95 library (MKL or Netlib)

Input Variables
^^^^^^^^^^^^^^^

``USEMKL``
  specifies to search for MKL Lapack95 instead of Netlib.

Result Variables
^^^^^^^^^^^^^^^^

``LAPACK95_FOUND``
  System has the LAPACK95 library
``LAPACK95_INCLUDE_DIRS``
  LAPACK95 header files
``LAPACK95_LIBRARIES``
  LAPACK95 libraries  

#]=======================================================================]


if(USEMKL OR CMAKE_Fortran_COMPILER_ID STREQUAL Intel)

  find_path(LAPACK95_INCLUDE_DIR 
            NAMES lapack95.mod
            PATHS $ENV{MKLROOT}/include 
                  $ENV{MKLROOT}/include/intel64/lp64
                  NO_DEFAULT_PATH)
          
  foreach(slib mkl_blas95_lp64 mkl_lapack95_lp64 mkl_intel_lp64 mkl_sequential mkl_core)
    find_library(LAPACK95_${slib}_LIBRARY
             NAMES ${slib}
             PATHS $ENV{MKLROOT}/lib
                   $ENV{MKLROOT}/lib/intel64
                   $ENV{INTEL}/mkl/lib/intel64
             NO_DEFAULT_PATH)
    if(NOT LAPACK95_${slib}_LIBRARY)
      message(FATAL_ERROR "NOT FOUND: " ${slib} ${LAPACK95_${slib}_LIBRARY})
    endif()
#    message(STATUS "Intel MKL LAPACK95 FOUND: " ${slib} ${LAPACK95_${slib}_LIBRARY})
    list(APPEND LAPACK95_LIBRARY ${LAPACK95_${slib}_LIBRARY})
    mark_as_advanced(LAPACK95_${slib}_LIBRARY)
  endforeach()
  list(APPEND LAPACK95_LIBRARY pthread dl m)

else()
  set(BLA_F95 OFF)
  find_package(LAPACK REQUIRED)

  find_library(LAPACK95_LIBRARY
               NAMES lapack95.a)

  find_path(LAPACK95_INCLUDE_DIR
            NAMES f95_lapack.mod
            PATH_SUFFIXES lapack95_modules)

endif()


include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LAPACK95
    REQUIRED_VARS LAPACK95_LIBRARY LAPACK95_INCLUDE_DIR)

if(LAPACK95_FOUND)
  set(LAPACK95_LIBRARIES ${LAPACK95_LIBRARY} ${LAPACK_LIBRARIES})  # MUST be in this order!
  set(LAPACK95_INCLUDE_DIRS ${LAPACK95_INCLUDE_DIR} ${LAPACK_INCLUDE_DIRS})
endif()

mark_as_advanced(LAPACK95_INCLUDE_DIR LAPACK95_LIBRARY)

