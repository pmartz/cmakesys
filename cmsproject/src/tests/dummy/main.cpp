// Copyright


#include <types.h>

#include <iostream>


bool test()
{
    std::cout << "Dummy test." << std::endl;
    {
        if( false )
        {
            std::cerr << "FAILED: Should never be here." << std::endl;
            return( false );
        }
    }

    return( true );
}

int main( int argc, char** argv )
{
    std::cout << "This is a CTest executable." << std::endl;
    std::cout << "In VS, build the RUN_TESTS target." << std::endl;
    std::cout << "In Linux, 'make test'." << std::endl;
    std::cout << std::endl;

    if( !test() )
    {
        std::cout << "\nTest failed." << std::endl;
        return( 1 );
    }

    std::cout << "\nTest passed." << std::endl;
    return( 0 );
}
