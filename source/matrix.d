//=============================================================================
//
// Purpose: Matrix class for vector manipulation
//
//=============================================================================

module matrix;

import vector;
import std.math;

enum MATRIX_SIZE = 4;

class Matrix_4x4
{
public:
	this()
	{
		m = new float[][]( MATRIX_SIZE, MATRIX_SIZE );
	}

	this ( float[][] matrix )
	{
		// Make sure this is a 4x4 array
		assert( matrix.length == MATRIX_SIZE && matrix[0].length == MATRIX_SIZE );

		this();
		setMatrix( matrix );
	}

	size_t numRows() { return MATRIX_SIZE; }
	size_t numCols() { return MATRIX_SIZE; }

	void setRow( float[] row, size_t num )
	{
		// Only 4 rows
		assert( num < MATRIX_SIZE );
		m[num] = row;
	}

	void setCol( float[] col, size_t num )
	{
		// Only 4 columns
		assert( num < MATRIX_SIZE );

		for ( int i = 0; i < numRows(); ++i )
		{
			m[i][num] = col[i];
		}
	}

	// NOTE: test this out
	void setMatrix( float[][] matrix )
	{
		// Make sure this is a 4x4 array
		assert( matrix.length == 4 && matrix[0].length == 4 );

		for ( size_t i = 0; i < numRows(); ++i )
		{
			for ( size_t j = 0; j < numCols(); ++j )
			{
				m[i][j] = matrix[i][j];
			}
		}
	}

	Matrix_4x4 transpose()
	{
		Matrix_4x4 result = new Matrix_4x4();
		for ( size_t i = 0; i < numRows(); ++i )
		{
			for ( size_t j = 0; j < numCols(); ++j )
			{
				result[i, j] = m[j][i];
			}
		}

		return result;
	}

	Matrix_4x4 invert()
	{
		return null;
	}

	// Multiply m by a scalar
	Matrix_4x4 multiply( float scalar )
	{
		Matrix_4x4 result = new Matrix_4x4();
		for ( size_t i = 0; i < this.numRows(); ++i )
		{
			for ( size_t j = 0; j < this.numCols(); ++j )
			{
				result[i, j] = m[i][j] * scalar;
			}
		}

		return result;
	}

	// Rotate about the x-axis
	Matrix_4x4 rotateX( float angle )
	{
		float sinf = sin( angle );
		float cosf = cos( angle );

		float[][] m = [[1.0f, 0.0f, 0.0f, 0.0f], [0.0f, cosf, -sinf, 0.0f], [0.0f, sinf, cosf, 0.0f], [0.0f, 0.0f, 0.0f, 1.0f]];
		Matrix_4x4 matrix = new Matrix_4x4( m );
		return this * matrix;
	}

	// Rotate about the y-axis
	Matrix_4x4 rotateY( float angle )
	{
		float sinf = sin( angle );
		float cosf = cos( angle );

		float[][] m = [[cosf, 0.0f, sinf, 0.0f], [0.0f, 1.0f, 0.0f, 0.0f], [-sinf, 0.0f, cosf, 0.0f], [0.0f, 0.0f, 0.0f, 1.0f]];
		Matrix_4x4 matrix = new Matrix_4x4( m );
		return this * matrix;
	}

	// Rotate about the z-axis
	Matrix_4x4 rotateZ( float angle )
	{
		float sinf = sin( angle );
		float cosf = cos( angle );

		float[][] m = [[cosf, -sinf, 0.0f, 0.0f], [sinf, cosf, 0.0f, 0.0f], [0.0f, 0.0f, 0.0f, 1.0f],  [0.0f, 0.0f, 0.0f, 1.0f]];
		Matrix_4x4 matrix = new Matrix_4x4( m );
		return this * matrix;
	}

	// Rotate about an arbitrary axis defined as a vector
	Matrix_4x4 rotate( Vec4f axis, float angle )
	{
		float sinf = sin( angle );
		float cosf = cos( angle );

		float[][] m = [[( axis.x * axis.x ) * ( 1.0f - cosf ) + cosf, ( axis.x * axis.y ) * ( 1 - cosf ) - ( axis.z * sinf ), ( axis.x * axis.z ) * ( 1.0f - cosf ) + ( axis.y * sinf ), 0.0f],
					   [( axis.x * axis.y ) * ( 1.0f - cosf ) + ( axis.z * sinf ), ( axis.y * axis.y ) * ( 1.0f - cosf ) + cosf, ( axis.y * axis.z ) * ( 1.0f - cosf ) - ( axis.x * sinf ), 0.0f],
		[( axis.x * axis.z ) * ( 1.0f - cosf ) - ( axis.y * sinf ), ( axis.y * axis.z ) * ( 1.0f - cosf ) + ( axis.x * sinf ), ( axis.z * axis.z ) * ( 1.0f - cosf ) + cosf, 0.0f],
		[0.0f, 0.0f, 0.0f, 1.0f]];
		Matrix_4x4 matrix = new Matrix_4x4( m );
		return this * matrix;
	}

	// Transform a vector using this matrix
	Vec4f transform( Vec4f vec )
	{
		return new Vec4f( m[0][0] * vec.x + m[0][1] * vec.y + m[0][2] * vec.z + m[0][3] * vec.w,
						  m[1][0] * vec.x + m[1][1] * vec.y + m[1][2] * vec.z + m[1][3] * vec.w,
						  m[2][0] * vec.x + m[2][1] * vec.y + m[2][2] * vec.z + m[2][3] * vec.w,
						  m[3][0] * vec.x + m[3][1] * vec.y + m[3][2] * vec.z + m[3][3] * vec.w );
	}

	// Operator overloading
	float opIndex( size_t i, size_t j ) { return m[i][j]; }
	float opIndexAssign( float value, size_t i, size_t j ) 
	{
		m[i][j] = value;
		return value;
	}

	// Operations on two matrices
	Matrix_4x4 opBinary( string op )( Matrix_4x4 other )
	{
		Matrix_4x4 result = new Matrix_4x4();

		// Mult
		if ( op == "*" )
		{
			for ( size_t i = 0; i < this.numRows; ++i )
			{
				for ( size_t j = 0; j < other.numCols(); ++j )
				{
					result[i, j] = 0.0f;
					for ( size_t k = 0; k < this.numCols(); ++k )
					{
						result[i, j] = result[i, j] + ( m[i][k] * other[k, j] );
					}
				}
			}
		}
		else if ( op == "+" )
		{
			for ( size_t i = 0; i < this.numRows; ++i )
			{
				for ( size_t j = 0; j < this.numCols; ++i )
				{
					result[i, j] = m[i][j] + other[i, j];
				}
			}
		}

		return result;
	}

private:
	float[][] m;
}

// Inlined functions
pragma( inline ) float radiansToDegrees( float r )
{
	return r * ( 180 / PI );
}

pragma( inline ) float degreesToRadians( float d )
{
	return d * ( PI / 180 );
}

// Matrix of our screen space
pragma( inline ) Matrix_4x4 viewportTransform( float halfWidth, float halfHeight )
{
	float[][] m = [[halfWidth, 0.0f, 0.0f, halfWidth], 
				   [0.0f, -halfHeight, 0.0f, halfHeight], 
				   [0.0f, 0.0f, 0.5f, 0.5f], 
				   [0.0f, 0.0f, 0.0f, 1.0f]];

	return new Matrix_4x4( m );
}

// Identity matrix
pragma( inline ) Matrix_4x4 identity()
{
	Matrix_4x4 iden = new Matrix_4x4();
	for ( size_t i = 0; i < iden.numRows(); ++i )
	{
		for ( size_t j = 0; j < iden.numCols(); ++j )
		{
			iden[i, j] = ( i == j ) ? 1.0f : 0.0f;
		}
	}

	return iden;
}

// Perspective matrix
// FOV = field of view in radians
// zNear/zFar = mappings for z from 0 to 1
Matrix_4x4 perspective( float FOV, float aspectRatio, float zNear, float zFar )
{
	float invScale = tan( FOV / 2 );
	float zRange = zNear - zFar;

	float[][] m = [[1 / ( invScale * aspectRatio ), 0.0f, 0.0f, 0.0f],
				   [0.0f, 1.0f / invScale, 0.0f, 0.0f],
				   [0.0f, 0.0f, (-zNear -zFar) / zRange, ( 2 * zFar * zNear ) / zRange],
				   [0.0f, 0.0f, 1.0f, 0.0f]];
	return new Matrix_4x4( m );
}