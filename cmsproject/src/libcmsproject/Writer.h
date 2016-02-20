// Copyright

#ifndef __CMSPROJECT_WRITER_H__
#define __CMSPROJECT_WRITER_H__ 1


#include <export.h>
#include <types.h>


/** \class Writer Writer.h
*/
class CMSPROJECT_EXPORT Writer
{
public:
    typedef enum {
        CSV_WRITER
    } WriterType;

    Writer( const WriterType writerType );
    virtual ~Writer();

    // This is a factory design pattern
    static WriterPtr create( const WriterType writerType );

    WriterType getType() const;

protected:
    WriterType _writerType;
};


// __CMSPROJECT_WRITER_H__
#endif
