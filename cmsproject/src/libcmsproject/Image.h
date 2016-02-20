// Copyright

#ifndef __CMSPROJECT_IMAGE_H__
#define __CMSPROJECT_IMAGE_H__ 1


#include <export.h>
#include <types.h>
#include <string>


/** \class Image Image.h
*/
class CMSPROJECT_EXPORT Image
{
public:
    Image();
    virtual ~Image();

    /** Grabs an image from a webcam.
    **/
    int loadImage();

    /** Writes image data out to a file.
    **/
    int writeImage( const std::string& fileName );

    /** Computes the absolute difference of two images
    and stores the result.
    **/
    void absDiff( const Image& image0, const Image& image1 );

protected:
    unsigned char* _data;
    int _w, _h;
    int _bytesPerPixel, _bytesPerRow;
};


// __CMSPROJECT_IMAGE_H__
#endif

