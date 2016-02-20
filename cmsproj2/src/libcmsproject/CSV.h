// Copyright

#ifndef __CMSPROJECT_CSV_H__
#define __CMSPROJECT_CSV_H__ 1


#include <export.h>
#include <types.h>
#include <string>
#include <vector>


typedef std::vector< DoubleSimpleVec > DataArray;


/** \brief
\details
*/
class CMSPROJECT_EXPORT CSV
{
public:
    CSV( const std::string& inFile=std::string("") );
    CSV( const unsigned int cols, const unsigned int rows );
    CSV( const CSV& rhs );
    virtual ~CSV();

    void reset();
    bool valid() const;

    void getDims( unsigned int& cols, unsigned int& rows ) const;

    void resize( const unsigned int cols, const unsigned int rows );

    double& operator()( const unsigned int col, const unsigned int row );
    double operator()( const unsigned int col, const unsigned int row ) const;

    void debugJumpDistance( const bool debug=true );
    float jumpDistance() const;

    DoubleSimpleVec& getRow( const unsigned int rdx );
    const DoubleSimpleVec& getRow( const unsigned int rdx ) const;

    void setColLabel( const unsigned int col, const std::string& label );
    void setRowLabel( const unsigned int row, const std::string& label );
    std::string getColLabel( const unsigned int col ) const;
    std::string getRowLabel( const unsigned int row ) const;
    void setRowColLabel( const std::string& label );
    std::string getRowColLabel() const;

    bool write( const std::string& outFile ) const;

protected:
    bool load( const std::string& inFile );

    void tokenize( StringSimpleVec& result, const std::string& line );

    unsigned int _cols, _rows;
    StringSimpleVec _colLabels, _rowLabels;
    std::string _rowColLabel;

    DataArray _data;

    bool _accessEnabled;
    long long _lastAccess, _distance;
    long long _accessCount;
};


// __CMSPROJECT_CSV_H__
#endif
