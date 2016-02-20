// Copyright


#include "Image.h"
#include "jpeglib.h"
#include <iostream>
#include <stdlib.h>
#include <string>


Image::Image()
  : _data( NULL ),
    _w( 0 ),
    _h( 0 ),
    _bytesPerPixel( 0 ),
    _bytesPerRow( 0 )
{
}
Image::~Image()
{
    if( _data != NULL )
    {
        free( _data );
        _data = NULL;
    }
}

int Image::loadImage()
{
    const std::string fileName( "0-temp.jpg" );

    const std::string fswebcamCmd(
        "/usr/bin/fswebcam \
        -r 640x480 \
        -q -S 3 " );
    int result = system( ( fswebcamCmd + fileName ).c_str() );
    if( result != 0 )
    {
        std::cerr << "Failed to capture image: " << result << std::endl;
        return( result );
    }

    // Open the file with libJPEG. Allocate and store
    // the raw pixel array.
    struct jpeg_decompress_struct cInfo;
    struct jpeg_error_mgr jerr;
    JSAMPARRAY buffer;
    int rowStride;

    FILE* inFile;
    if( ( inFile = fopen( fileName.c_str(), "rb" ) ) == NULL )
    {
        std::cerr << "Can't open image for reading." << std::endl;
        return( 1 );
    }

    cInfo.err = jpeg_std_error( &jerr );
    jpeg_create_decompress( &cInfo );

    jpeg_stdio_src( &cInfo, inFile );
    jpeg_read_header( &cInfo, TRUE );
    jpeg_start_decompress( &cInfo );
    _w = cInfo.output_width;
    _h = cInfo.output_height;
    _bytesPerPixel = cInfo.output_components;
    _bytesPerRow = cInfo.output_width * _bytesPerPixel;

    _data = (unsigned char*)( malloc(
        _bytesPerRow * cInfo.output_height ) );
    unsigned char* ptr( _data );

    buffer = ( *cInfo.mem->alloc_sarray )( 
        ( j_common_ptr )&cInfo, JPOOL_IMAGE, _bytesPerRow, 1 );
    while( cInfo.output_scanline < cInfo.output_height )
    {
        // Reads 1 scanline at a time but could enlarge buffer
        // and ask for all scanlines.
        jpeg_read_scanlines( &cInfo, buffer, 1 );

        for( int idx=0; idx < _bytesPerRow; idx++ )
            *ptr++ = 0;// buffer[0][ idx ];
    }

    jpeg_finish_decompress( &cInfo );
    jpeg_destroy_decompress( &cInfo );
    fclose( inFile );

    return( 0 );
}

int Image::writeImage( const std::string& fileName )
{
    return( 0 );
}

void Image::absDiff( const Image& image0, const Image& image1 )
{
}

