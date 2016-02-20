// Copyright

#ifndef __CMSPROJECT_EXPORT_H__
#define __CMSPROJECT_EXPORT_H__ 1


#if defined( _MSC_VER ) || defined( __CYGWIN__ ) || defined( __MINGW32__ ) || defined( __BCPLUSPLUS__ ) || defined( __MWERKS__ )
    #if defined( CMSPROJECT_STATIC )
        #define CMSPROJECT_EXPORT
    #elif defined( CMSPROJECT_LIBRARY )
        #define CMSPROJECT_EXPORT __declspec( dllexport )
    #else
        #define CMSPROJECT_EXPORT __declspec( dllimport )
    #endif
#else
    #define CMSPROJECT_EXPORT
#endif


// __CMSPROJECT_EXPORT_H__
#endif
