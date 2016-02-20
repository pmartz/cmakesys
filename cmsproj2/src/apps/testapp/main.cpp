#include "version.h"
#include "Image.h"
#include <iostream>


int main( int argc, char** argv )
{
    std::cout << CMSPROJECT_VERSION_STRING << std::endl;

    Image* img( new Image() );
    img->loadImage();

    return( 0 );
}
