# Install all files from _srcDir ti _destDir.
#   _srcDir - Directory of files to install.
#   _destDir - Relative destincation install directory.
set( _srcDir ${PROJECT_SOURCE_DIR}/data/ )
set( _destDir share/smsrail/data )

install(
    DIRECTORY ${_srcDir} 
    DESTINATION ${_destDir}
    USE_SOURCE_PERMISSIONS
    COMPONENT smsrail-dev
    FILES_MATCHING PATTERN "*"
    PATTERN "CMakeLists.txt" EXCLUDE
    PATTERN ".svn" EXCLUDE
    PATTERN ".DS_Store" EXCLUDE
)
