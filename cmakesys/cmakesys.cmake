
#
# _zeroPad
#
# Assumes the input string is a number. If necessary, the
# number is 0-padded to two digits.
#
macro( _zeroPad _input _output )
    if( ${${_input}} LESS 10 )
        set( ${_output} "0${${_input}}" )
    else()
        set( ${_output} "${${_input}}" )
    endif()
endmacro()

#
# _listGet
#
# If _keyword is present in ${ARGN}, _result is set to
# the the following space-delimited token. If there is no
# following token, a warning is displayed and _result is unchanged.
# If _keyword is not found, no action is taken.
macro( _listGet _keyword _result )
    set( _tempList ${ARGN} )
    list( FIND _tempList ${_keyword} _temp )
    if( ${_temp} GREATER -1 )
        math( EXPR _valueIndex "${_temp}+1" )
        list( LENGTH _tempList _listLen )
        if( ${_valueIndex} LESS ${_listLen} )
            list( GET _tempList ${_valueIndex} ${_result} )
        else()
            message( WARNING "_listGet keyword ${_keyword} present, but missing parameter." )
        endif()
    endif()
endmacro()

#
# _listFindBool
#
# Like the list(FIND...) CMake macro, but returns a boolean
# result. The _result parameter is set to TRUE if _keyword is
# present anywhere in ${ARGN}. Otherwise, _result is set to FALSE.
macro( _listFindBool _keyword _result )
    set( _tempList ${ARGN} )
    list( FIND _tempList ${_keyword} _temp )
    if( ${_temp} LESS 0 )
        set( ${_result} FALSE )
    else()
        set( ${_result} TRUE )
    endif()
endmacro()

#
# _projectName
#
# Sets the project name and creates an uppercase variant.
# CMAKE_PROJECT_NAME is set to the given _name.
# _projectNameUpper it set to _name comverted to uppercase.
macro( _projectName _name )
    project( ${_name} )
    string( TOUPPER ${_name} _projectNameUpper )
endmacro()

#
# _projectVersion
#
# Usage:
#   _projectVersion( <maj> <min> <sub>
#                    [ZEROPAD] )
#
# Usage note: Set the project name with _projectName(...)
# before invoking this macro.
#
# Sets project version variables and auto-configures a Version.h header file.
# Sets these variables:
#   ${_projectNameUpper}_MAJOR_VERSION to "${_maj}"
#   ${_projectNameUpper}_MINOR_VERSION to "${_min}"
#   ${_projectNameUpper}_SUB_VERSION to "${_sub}"
#
# This macro also sets a variable called ${_projectNameUpper}_VERSION, which
# contains a combined version number. The setting of this variable is
# controlled with the presence of ZEROPAD. If not present,
# ${_projectNameUpper}_VERSION is set to "${_maj}.${_min}.${_sub}". If
# ZEROPAD is present, _min and _sub are zero-padded to two digits. (Compare:
# "3.0.1" or "3.00.01" when ZEROPAD is specified.)
#
# _projectVersion is set to the value of ${_projectNameUpper}_VERSION.
#
# This macro also sets ${_projectNameUpper}_VERSION_COMPACT in the same way
# as ${_projectNameUpper}_VERSION, but with no intervening periods ("301" or
# "30001" when ZEROPAD is specified.)
#
# TBD install?
macro( _projectVersion _maj _min _sub )
    if( NOT _projectNameUpper )
        message( WARNING "_projectVersion: _projectNameUpper not set. You must invoke _projectName(...) before _projectVersion(...)." )
    endif()

    set( ${_projectNameUpper}_MAJOR_VERSION ${_maj}
        CACHE INTERNAL "Project major vertion number" FORCE )
    set( ${_projectNameUpper}_MINOR_VERSION ${_min}
        CACHE INTERNAL "Project minor vertion number" FORCE )
    set( ${_projectNameUpper}_SUB_VERSION ${_sub}
        CACHE INTERNAL "Project sub vertion number" FORCE )

    set( _minorPad ${_min} )
    set( _subPad ${_sub} )
    _listFindBool( ZEROPAD _pad ${ARGN} )
    if( ${_pad} )
        _zeroPad( _minorPad _minorPad )
        _zeroPad( _subPad _subPad )
    endif()

    set( ${_projectNameUpper}_VERSION "${_maj}.${_minorPad}.${_subPad}" )
    set( _projectVersion ${${_projectNameUpper}_VERSION} )
    set( ${_projectNameUpper}_VERSION_COMPACT "${_maj}${_minorPad}${_subPad}" )

    _listGet( HEADER_SOURCE _headerSource ${ARGN} )
    _listGet( HEADER_DEST _headerDest ${ARGN} )
    if( _headerSource AND _headerDest )
        configure_file( ${_headerSource} ${_headerDest} )
    endif()
endmacro()

#
# _useBinLibStructure
#
# Sets the CMake variables that control the location of project
# executables, libraries, and plugins.
macro( _useBinLibStructure )
    set( CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin )
    set( CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib )
    if( WIN32 )
        # Libraries (DLLs) go where executables go.
        set( CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY} )
    else()
        # Libraries (SOs) go where stub libs go.
        set( CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY} )
    endif()
endmacro()

#
# _doxygen
#
# Parameters:
#   DOXYFILE_SOURCE <file>
#     If present, <file> is processed by configure_file() and the
#     output is used as the Doxygen configuration file. If not
#     present, <sourcedir>/doc/doxyfile.in is used if it exists.
#     Otherwise, a warning is displayed.
macro( _doxygen )
    find_package( Doxygen )
    if( DOXYGEN_FOUND )
        set( HAVE_DOT "NO" )
        if( DOXYGEN_DOT_PATH )
            set( HAVE_DOT "YES" )
        endif()

        set( _doxyfileSource "" )
        _listGet( DOXYFILE_SOURCE _doxyfileSource ${ARGN} )
        if( _doxyfileSource STREQUAL "" )
            if( EXISTS ${PROJECT_SOURCE_DIR}/doc/doxyfile.in )
                set( _doxyfileSource ${PROJECT_SOURCE_DIR}/doc/doxyfile.in )
            else()
                message( WARNING "_doxygen: Can't find doxyfile source." )
            endif()
        endif()

        configure_file( ${_doxyfileSource}
            ${PROJECT_BINARY_DIR}/doc/doxyfile
        )
        add_custom_target( Documentation
            ${DOXYGEN_EXECUTABLE} ${PROJECT_BINARY_DIR}/doc/doxyfile
        )

        if( EXISTS ${PROJECT_SOURCE_DIR}/doc/images/CMakeLists.txt )
            add_subdirectory( doc/images )
        endif()
    endif()
endmacro()
