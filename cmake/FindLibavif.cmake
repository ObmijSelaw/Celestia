# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#.rst:
# FindLibavif
# --------
#
# Find the avif headers and libraries.

# First try pkg-config
find_package(PkgConfig QUIET)
if(PKG_CONFIG_FOUND)
  pkg_check_modules(PC_LIBAVIF QUIET libavif)
endif()

find_path(LIBAVIF_INCLUDE_DIR
          NAMES avif/avif.h
          HINTS ${PC_LIBAVIF_INCLUDEDIR} ${PC_LIBAVIF_INCLUDE_DIRS} LIBAVIF_DIR
          PATH_SUFFIXES include
          DOC "avif headers")

find_library(LIBAVIF_LIBRARY
             NAMES avif
             HINTS ${PC_LIBAVIF_LIBDIR} ${PC_LIBAVIF_LIBRARY_DIRS} LIBAVIF_DIR
             PATH_SUFFIXES lib lib64
             DOC "avif libraries")

mark_as_advanced(LIBAVIF_INCLUDE_DIR LIBAVIF_LIBRARY)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Libavif
                                  FOUND_VAR LIBAVIF_FOUND
                                  REQUIRED_VARS LIBAVIF_INCLUDE_DIR LIBAVIF_LIBRARY
                                  FAIL_MESSAGE "Failed to find avif")

if(LIBAVIF_FOUND)
  set(LIBAVIF_INCLUDE_DIRS "${LIBAVIF_INCLUDE_DIR}")
  if(LIBAVIF_LIBRARY)
    set(LIBAVIF_LIBRARIES "${LIBAVIF_LIBRARY}")
  else()
    unset(LIBAVIF_LIBRARIES)
  endif()

  if(NOT TARGET libavif::libavif)
    add_library(libavif::libavif UNKNOWN IMPORTED)
    set_target_properties(libavif::libavif PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${LIBAVIF_INCLUDE_DIRS}")
    set_target_properties(libavif::libavif PROPERTIES
      IMPORTED_LOCATION "${LIBAVIF_LIBRARY}")
  endif()
endif()
