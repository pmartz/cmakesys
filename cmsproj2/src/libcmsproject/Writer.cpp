// Copyright


#include "Writer.h"
#include "CSVWriter.h"
#include <iostream>


Writer::Writer( const WriterType writerType )
    : _writerType( writerType )
{
}
Writer::~Writer()
{
}

WriterPtr Writer::create( const WriterType writerType )
{
    switch( writerType )
    {
    case CSV_WRITER:
        {
            CSVWriterPtr writer( new CSVWriter() );
            return( writer );
        }
        break;

    default:
        std::cerr << "Writer::create(): Invalid WriterType." << std::endl;
        return( WriterPtr( (Writer*)NULL ) );
        break;
    }
}
Writer::WriterType Writer::getType() const
{
    return( _writerType );
}
