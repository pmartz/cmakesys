// Copyright

#ifndef __CMSPROJECT_CSV_WRITER_H__
#define __CMSPROJECT_CSV_WRITER_H__ 1


#include <export.h>
#include <Writer.h>
#include <memory>


/** \class CSVWriter CSVWriter.h
*/
class CMSPROJECT_EXPORT CSVWriter : public Writer
{
public:
    CSVWriter();
    virtual ~CSVWriter();

protected:
};

typedef std::shared_ptr< CSVWriter > CSVWriterPtr;


// __CMSPROJECT_CSV_WRITER_H__
#endif
