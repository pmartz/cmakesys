// Copyright


#include "CSV.h"
#include <fstream>
#include <iostream>
#include <sstream>


CSV::CSV( const std::string& inFile )
    : _cols( 0 ),
    _rows( 0 ),
    _accessEnabled( false )
{
    if( !( inFile.empty() ) )
    {
        if( !( load( inFile ) ) )
        {
            // Display error.
        }
    }
}
CSV::CSV( const unsigned int cols, const unsigned int rows )
    : _cols( cols ),
    _rows( rows ),
    _accessEnabled( false )
{
    _colLabels.resize( cols );
    _rowLabels.resize( rows );
    _data.resize( rows );
    for( unsigned int idx=0; idx < rows; ++idx )
        _data[ idx ].resize( cols );
}
CSV::CSV( const CSV& rhs )
    : _cols( rhs._cols ),
    _rows( rhs._rows ),
    _colLabels( rhs._colLabels ),
    _rowLabels( rhs._rowLabels ),
    _rowColLabel( rhs._rowColLabel ),
    _data( rhs._data ),
    _accessEnabled( false )
{
}
CSV::~CSV()
{
}

void CSV::reset()
{
    _colLabels.clear();
    _rowLabels.clear();
    _rowColLabel = "";
    _cols = _rows = 0;
    _data.clear();
}
bool CSV::valid() const
{
    return( ( _cols != 0 ) && ( _rows != 0 ) );
}

void CSV::getDims( unsigned int& cols, unsigned int& rows ) const
{
    cols = _cols;
    rows = _rows;
}

void CSV::resize( const unsigned int cols, const unsigned int rows )
{
    _cols = cols;
    _rows = rows;
    _data.resize( rows );
    for( unsigned int idx=0; idx < rows; ++idx )
        _data[ idx ].resize( cols );
    _colLabels.resize( cols );
    _rowLabels.resize( rows );
}

double& CSV::operator()( const unsigned int col, const unsigned int row )
{
    if( _accessEnabled )
    {
        if( _lastAccess != 0 )
        {
            const int distance( std::abs(
                    (int)(&( _data[ row ][ col ] )) - _lastAccess ) );
            _distance += distance;
        }
        _lastAccess = (int)(&( _data[ row ][ col ] ));
        ++_accessCount;
    }

    return( _data[ row ][ col ] );
}
double CSV::operator()( const unsigned int col, const unsigned int row ) const
{
    return( _data[ row ][ col ] );
}

void CSV::debugJumpDistance( const bool debug )
{
    _accessEnabled = debug;
    if( _accessEnabled )
    {
        _lastAccess = _distance = 0;
        _accessCount = 0;
    }
}
float CSV::jumpDistance() const
{
    const float distance( (float) _distance );
    return( distance / (float)_accessCount );
}

DoubleSimpleVec& CSV::getRow( const unsigned int rdx )
{
    return( _data[ rdx ] );
}
const DoubleSimpleVec& CSV::getRow( const unsigned int rdx ) const
{
    return( _data[ rdx ] );
}

void CSV::setColLabel( const unsigned int col, const std::string& label )
{
    _colLabels[ col ] = label;
}
void CSV::setRowLabel( const unsigned int row, const std::string& label )
{
    _rowLabels[ row ] = label;
}
std::string CSV::getColLabel( const unsigned int col ) const
{
    return( _colLabels[ col ] );
}
std::string CSV::getRowLabel( const unsigned int row ) const
{
    return( _rowLabels[ row ] );
}
void CSV::setRowColLabel( const std::string& label )
{
    _rowColLabel = label;
}
std::string CSV::getRowColLabel() const
{
    return( _rowColLabel );
}


bool CSV::write( const std::string& outFile ) const
{
    if( !valid() )
        return( false );

    std::ofstream ofstr( outFile.c_str() );
    if( ofstr.bad() )
        return( false );

    // Write column headers.
    ofstr << _rowColLabel;
    for( unsigned int idx=0; idx < _colLabels.size(); ++idx )
    {
        ofstr << ",";
        if( _colLabels[ idx ].empty() )
            ofstr << "c" << idx+1;
        else
            ofstr << _colLabels[ idx ];
    }
    ofstr << std::endl;

    for( unsigned int idx=0; idx < _rows; ++idx )
    {
        if( _rowLabels[ idx ].empty() )
            ofstr << "r" << idx+1;
        else
            ofstr << _rowLabels[ idx ];

        const DoubleSimpleVec& thisRow( _data[ idx ] );
        for( unsigned int v=0; v < thisRow.size(); ++v )
        {
            ofstr << "," << thisRow[ v ];
        }
        ofstr << std::endl;
    }

    return( true );
}

bool CSV::load( const std::string& inFile )
{
    reset();

    std::ifstream ifstr;
    ifstr.open( inFile.c_str(), std::ios::in );
    if( ifstr.bad() ) return( false );


    //
    // Find the first line and store it as column headers.

    std::string line;
    do {
        std::getline( ifstr, line );
    } while( line.empty() && ifstr.good() );
    if( ifstr.bad() ) return( false );

    StringSimpleVec colLabels;
    tokenize( colLabels, line );
    if( colLabels.empty() )
    {
        std::cerr << "Error reading column headers." << std::endl;
        return( false );
    }
    _rowColLabel = colLabels[ 0 ];

    _colLabels.resize( colLabels.size() - 1 );
    for( unsigned int idx=1; idx < colLabels.size(); ++idx )
        _colLabels[ idx-1] = colLabels[ idx ];

    _cols = (unsigned int)( _colLabels.size() );


    //
    // Read and process each line in the file.

    while( std::getline( ifstr, line ) && ifstr.good() )
    {
        StringSimpleVec tokens;
        tokenize( tokens, line );
        if( tokens.empty() || ( tokens.size() != _colLabels.size() + 1 ) )
        {
            std::cerr << "Problem reading CSV values." << std::endl;
            return( false );
        }
        _data.resize( ++_rows );
        _data[ _data.size()-1 ].resize( _cols );

        // Label for this row.
        _rowLabels.push_back( tokens[ 0 ] );

        for( unsigned int idx=1; idx < tokens.size(); ++idx )
        {
            double value( atof( tokens[ idx ].c_str() ) );
            _data[ _rows-1 ][ idx-1 ] = value;
        }
    }

    if( ( _rows == 0 ) || ( _cols == 0 ) )
    {
        reset();
        return( false );
    }
    return( true );
}

void CSV::tokenize( StringSimpleVec& result, const std::string& line )
{
    result.clear();

    std::string::size_type offset( 0 );
    std::string::size_type pos( line.find_first_of( ',', offset ) );
    while( pos != line.npos )
    {
        if( pos == offset )
        {
            // Empty token.
            result.push_back( "" );
            ++offset;
        }
        else
        {
            // Normal token
            result.push_back( line.substr( offset, pos-offset ) );
            offset = pos+1;
        }
        pos = line.find_first_of( ',', offset );
    }
    if( offset < line.size() )
    {
        // Last token.
        result.push_back( line.substr( offset ) );
    }
}

