cmake_minimum_required( VERSION 2.8.8 )
set( CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmakesys" ${CMAKE_MODULE_PATH} )
include( cmakesys )

_projectName( cmakesys )

_projectVersion( 0 1 0 ZEROPAD
    HEADER_SOURCE ${PROJECT_SOURCE_DIR}/cmakesys/templates/version.h.in
    HEADER_DEST ${PROJECT_SOURCE_DIR}/src/examples/version/version.h )

_useBinLibStructure()

_doxygen(
    DOXYFILE_SOURCE ${PROJECT_SOURCE_DIR}/cmakesys/templates/doxyfile.in
)

add_subdirectory( src )
