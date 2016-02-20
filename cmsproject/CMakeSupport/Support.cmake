
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
# the following space-delimited token. If there is no
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
# _listMemberAppend
#
# For each list element in _inList, prepend _prefix and
# append _suffix, and store the result in _outList. This macro
# does not modify _inList.
#
macro( _listMemberAppend _inList _outList _prefix _suffix )
    foreach( _item ${${_inList}} )
        list( APPEND ${_outList} ${_prefix}${_item}${_suffix} )
    endforeach()
endmacro()


#
# _projectName
#
# Sets the project name and creates an uppercase variant.
#   CMAKE_PROJECT_NAME is set to the given _name.
#   PROJECT_NAME is set to the given _name.
#   _projectNameUpper it set to _name comverted to uppercase.
macro( _projectName _name )
    # project() implicitly sets CMAKE_PROJECT_NAME and PROJECT_NAME
    project( ${_name} )
    # set _projectNameUpper
    string( TOUPPER ${_name} _projectNameUpper )
endmacro()


#
# _projectVersion
#
# Usage:
#   _projectVersion( <maj> <min> <sub>
#                    [ZEROPAD]
#                    [HEADER_SOURCE <headSrc>
#                    HEADER_DEST <headDest> )
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
# This macro sets PACKAGE_VERION to "${_maj}.${_min}.${_sub}".
# This variable is used during creation of the auto-find tools.
#
# This macro also sets a variable called ${_projectNameUpper}_VERSION, which
# contains a combined version number. The setting of this variable is
# controlled with the presence of ZEROPAD. If not present,
# ${_projectNameUpper}_VERSION is set to "${_maj}.${_min}.${_sub}". If
# ZEROPAD is present, _min and _sub are zero-padded to two digits. (Compare:
# "3.0.1" or "3.00.01" when ZEROPAD is specified.)
# Note that is ZEROPAD is absent, PACKAGE_VERION will have the
# same value as ${_projectNameUpper}_VERSION
#
# This macro also sets ${_projectNameUpper}_VERSION_COMPACT in the same way
# as ${_projectNameUpper}_VERSION, but with no intervening periods ("301" or
# "30001" when ZEROPAD is specified.)
#
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

    set( PACKAGE_VERSION "${_maj}.${_min}.${_sub}" )
    set( ${_projectNameUpper}_VERSION "${_maj}.${_minorPad}.${_subPad}" )
    set( ${_projectNameUpper}_VERSION_COMPACT "${_maj}${_minorPad}${_subPad}" )

    _listGet( HEADER_SOURCE _headerSource ${ARGN} )
    _listGet( HEADER_DEST _headerDest ${ARGN} )
    if( _headerSource AND _headerDest )
        configure_file( ${_headerSource} ${_headerDest} )
    endif()
endmacro()


#
# _outputDirs
#
# Sets the CMake output directory variables so that executables,
# libraries, and archives are all stored in a common bin directory.
# This makes it easy to find all executable code built by the project.
macro( _outputDirs )
    set( CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin )
    set( CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin )
    set( CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin )
endmacro()


#
# _installDirs
#
macro( _installDirs )
    # Set defaults.
    include( GNUInstallDirs )

    # Additional install directory for plugins (I.e., OSG-style).
    set( _installArchiveDir ${CMAKE_INSTALL_LIBDIR}
        CACHE PATH "Install directory for plugins" )

    # On Windows, no special directory for libraries.
    if( WIN32 )
        set( CMAKE_INSTALL_LIBDIR ${CMAKE_INSTALL_BINDIR} )
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
    if( NOT _projectNameUpper )
        message( WARNING "_doxygen: _projectNameUpper not set. You must invoke _projectName(...) before _doxygen(...)." )
    endif()

    # Do nothing if building documentation is disabled.
    if( NOT ${_projectNameUpper}_DOCUMENTATION )
        return()
    endif()

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




#
# _addLibrary
#
# If FORCE_STATIC is present, _addLibrary creates an archive
# rather than a library (a .lib rather than a .so). This happens
# regardless of the value of BUILD_SHARED_LIBS.
#
# TBD Need to add support for one project library linking
# against another. Right now, target_link_libraries links against
# only dependency libraries.
#
macro( _addLibrary _libName )
    # Check to see if we are forcing a static library.
    set( _optionsPlusFiles ${ARGN} )
    list( GET _optionsPlusFiles 0 _option )
    if( _option STREQUAL "FORCE_STATIC" )
        # Remove the FORCE_STATIC option, leaving only file names.
        list( REMOVE_AT _optionsPlusFiles 0 )
    endif()

    if( BUILD_SHARED_LIBS AND NOT ( _option STREQUAL "FORCE_STATIC" ) )
        add_library( ${_libName} SHARED ${_optionsPlusFiles} )
    else()
        add_library( ${_libName} STATIC ${_optionsPlusFiles} )
    endif()

    # Add "Lib" project label (for Visual Studio, primarily).
    set_target_properties( ${_libName}
        PROPERTIES PROJECT_LABEL "Lib ${_libName}" )

    # Building. Include dirs and CPP definitions.
    include_directories(
        ${_projectIncludes}
        ${_dependencyIncludes}
    )
    add_definitions( -D${_projectNameUpper}_LIBRARY )

    # Libraries to link against.
    # TBD need to support one library linking against another
    # from the same project.
    target_link_libraries( ${_libName}
        ${_dependencyLibraries}
    )

    # Add the library to the install target.
    install(
        TARGETS ${_libName}
        EXPORT ${CMAKE_PROJECT_NAME}-targets
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT ${CMAKE_PROJECT_NAME}
        ARCHIVE DESTINATION ${_installArchiveDir} COMPONENT ${CMAKE_PROJECT_NAME}-dev
    )

    # Install headers
    install(
        DIRECTORY .
        DESTINATION include/${_libName}
        USE_SOURCE_PERMISSIONS
        FILES_MATCHING 
        PATTERN "*.h"
        PATTERN ".txt" EXCLUDE
        PATTERN ".cpp" EXCLUDE
        PATTERN ".cxx" EXCLUDE
        PATTERN ".cc" EXCLUDE
    )
endmacro()


#
# _addExecutable
#
macro( _addExecutable CATAGORY _exeName )
    add_executable( ${_exeName} ${ARGN} )

    include_directories(
        ${_projectIncludes}
        ${_dependencyIncludes}
    )

    target_link_libraries( ${_exeName}
        ${_projectLibraries}
        ${_dependencyLibraries}
    )

    install(
        TARGETS ${_exeName}
        RUNTIME DESTINATION bin
        COMPONENT ${CMAKE_PROJECT_NAME}
    )

    set_target_properties( ${_exeName}
        PROPERTIES PROJECT_LABEL "${CATAGORY} ${_exeName}" )
    set_property( TARGET ${_exeName}
        PROPERTY DEBUG_OUTPUT_NAME "${_exeName}${CMAKE_DEBUG_POSTFIX}" )
endmacro()


#
# _windowsInstallPDB
#
# Install pdb files for Debug and RelWithDebInfo builds
macro( _windowsInstallPDB )
    if( MSVC )
        install(
            DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/\${CMAKE_INSTALL_CONFIG_NAME}/
            DESTINATION lib
            USE_SOURCE_PERMISSIONS
            COMPONENT ${CMAKE_PROJECT_NAME}-dev
            FILES_MATCHING PATTERN "*.pdb"
        )
    endif()
endmacro()


#
# _autoFindTools
#
# Create and install all CMake auto-find scripts.
macro( _autoFindTools )
    # Add project libraries to the <package>LibraryDepends.cmake
    # file so that downstream projects can find the libraries in
    # a build tree.
    if( EXISTS "${PROJECT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}/${CMAKE_PROJECT_NAME}LibraryDepends.cmake" )
        export( TARGETS ${_projectLibraries} APPEND
            FILE "${PROJECT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}/${CMAKE_PROJECT_NAME}LibraryDepends.cmake")
    else()
        export( TARGETS ${_projectLibraries}
            FILE "${PROJECT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}/${CMAKE_PROJECT_NAME}LibraryDepends.cmake")
    endif()

    # Export the package for use from the build-tree
    # (this registers the build-tree with a global CMake-registry)
    export( PACKAGE ${CMAKE_PROJECT_NAME} )

    # Create a BuildTreeSettings.cmake file for the use from the build tree
    configure_file( ${_supportDir}/PackageBuildTreeSettings.cmake.in
        "${PROJECT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}/${CMAKE_PROJECT_NAME}BuildTreeSettings.cmake" @ONLY )
    configure_file( ${_supportDir}/PackageConfigVersion.cmake.in
        "${PROJECT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}/${CMAKE_PROJECT_NAME}ConfigVersion.cmake" @ONLY )
    configure_file( ${_supportDir}/UsePackage.cmake.in
        "${PROJECT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}/Use${CMAKE_PROJECT_NAME}.cmake" @ONLY )

    include( CMakePackageConfigHelpers )
    # Create the <pkgname>Config.cmake and <pkgname>ConfigVersion files
    configure_package_config_file( 
        ${_supportDir}/PackageConfig.cmake.in 
            ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}/${CMAKE_PROJECT_NAME}Config.cmake
        INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}
        PATH_VARS ${VES_CONFIGURE_VARS} )

    install( FILES ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}/${CMAKE_PROJECT_NAME}Config.cmake
                   ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}/${CMAKE_PROJECT_NAME}ConfigVersion.cmake
                   ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}/Use${CMAKE_PROJECT_NAME}.cmake
             DESTINATION ${CMAKE_INSTALL_LIBDIR}
             COMPONENT development )

    # Install the CMake find script
    configure_file( ${_supportDir}/FindPackage.cmake.in
        "${PROJECT_BINARY_DIR}/Find${CMAKE_PROJECT_NAME}.cmake" @ONLY)
    install( FILES "${PROJECT_BINARY_DIR}/Find${CMAKE_PROJECT_NAME}.cmake"
        DESTINATION "share/${CMAKE_PROJECT_NAME}/extra"
        COMPONENT development )
        # RENAME Find${CMAKE_PROJECT_NAME}.cmake )

    # Install the export set for use with the install-tree
    install( EXPORT ${CMAKE_PROJECT_NAME}-targets
        DESTINATION ${CMAKE_INSTALL_LIBDIR}
        COMPONENT development )

    # TBD move this to the fpc cmake code
    # setup the fpc variables for the fpc file creation
    set( VES_FPC_PREFIX "\${fp_file_cwd}/../.." )
    if( CMAKE_LIBRARY_ARCHITECTURE )
        set( VES_FPC_PREFIX "\${fp_file_cwd}/../../.." )
    endif()
endmacro()


#
# _flagpoll
#
# Support for the flagpoll utility.
#
# TBD Need to iterate over all _projectLibraries and format
# each for storing in _fpcLibraries. Right now, this works
# if there is only one library.
macro( _flagpoll )
    set( _libPrefix )
    set( _libSuffix )
    if( WIN32 )
        set( _libSuffix ".lib" )
        set( _fpcLibraries "/libpath:${CMAKE_INSTALL_FULL_LIBDIR} " )
        set( _fpcIncludes "/I${CMAKE_INSTALL_FULL_INCLUDEDIR}" )
    else()
        set( _libPrefix "-l" )
        set( _fpcLibraries "-L${CMAKE_INSTALL_FULL_LIBDIR} " )
        set( _fpcIncludes "-I${CMAKE_INSTALL_FULL_INCLUDEDIR}" )
    endif()

    # Apply prefix and suffix to libraries, convert the lib list
    # to a space separated string, and append to _fpxLibraries.
    _listMemberAppend( _projectLibraries _appended "${_libPrefix}" "${_libSuffix}" )
    string( REPLACE ";" " " _outString "${_appended}" )
    set( _fpcLibraries "${_fpcLibraries}${_outString}" )

    # Expects _fpcLibraries and _fpxIncludes.
    configure_file( ${_supportDir}/fpc.in
        "${PROJECT_BINARY_DIR}/lib/flagpoll/${CMAKE_PROJECT_NAME}.fpc" @ONLY )

    install( FILES ${CMAKE_CURRENT_BINARY_DIR}/lib/flagpoll/${CMAKE_PROJECT_NAME}.fpc
             DESTINATION lib/flagpoll )
endmacro()

