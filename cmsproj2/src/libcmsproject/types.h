// Copyright

#ifndef __CMSPROJECT_TYPES_H__
#define __CMSPROJECT_TYPES_H__ 1


#include <vector>
#include <map>
#include <set>
#include <string>
#include <memory>


typedef std::vector< double > DoubleSimpleVec;
typedef std::vector< std::string > StringSimpleVec;
typedef std::vector< unsigned int > UIntSimpleVec;
typedef std::set< std::string > StringSet;

class Writer;
typedef std::shared_ptr< Writer > WriterPtr;


// __CMSPROJECT_TYPES_H__
#endif
