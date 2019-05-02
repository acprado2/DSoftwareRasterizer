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

	// Rotate about the x-axis
	Matrix_4x4 rotateX( float angle )
	{
		Matrix_4x4 matrix = initRotateX( angle );
		return this * matrix;
	}

	// Rotate about the y-axis
	Matrix_4x4 rotateY( float angle )
	{
		Matrix_4x4 matrix = initRotateY( angle );
		return this * matrix;
	}

	// Rotate about the z-axis
	Matrix_4x4 rotateZ( float angle )
	{
		Matrix_4x4 matrix = initRotateZ( angle );
		return this * matrix;
	}

	// Rotate about an arbitrary axis defined as a vector
	Matrix_4x4 rotate( Vec4f axis, float angle )
	{
		return this * initRotate( axis, angle );
	}

	// Scale
	Matrix_4x4 scale( Vec4f vec )
	{
		return this * initScale( vec );
	}

	// Translation
	Matrix_4x4 translate( Vec4f vec )
	{
		return this * initTranslation( vec );
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
					result[i, j] = m[i][0] * other[0, j] + 
								   m[i][1] * other[1, j] +
								   m[i][2] * other[2, j] + 
								   m[i][3] * other[3, j];
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

// Identity matrix
pragma( inline ) Matrix_4x4 identity()
{
	float[][] m = [[1, 0, 0, 0],
				   [0, 1, 0, 0],
				   [0, 0, 1, 0],
				   [0, 0, 0, 1]];

	return new Matrix_4x4( m );
}

// Create a lookat matrix for camera manipulation
/*pragma( inline ) Matrix_4x4 lookAt( Vec4f eye, Vec4f center, Vec4f up )
{
	Vec4f l_forward = ( eye - center ).normalized();
	Vec4f l_right = up.crossProduct( l_forward ).normalized();
	Vec4f l_up = l_forward.crossProduct( l_right );

	// Magic fast matrix inversion that only works with translation and rotation matrices
	float[][] m = [[l_right.x, l_up.x, l_forward.x, 0.0f],
				   [l_right.y, l_up.y, l_forward.y, 0.0f],
				   [l_right.z, l_up.z, l_forward.z, 0.0f],
				   [-l_right.dotProduct( eye ), -l_up.dotProduct( eye ), -l_forward.dotProduct( eye ), 1.0f]];

	return new Matrix_4x4( m );
}*/

// Create a lookat matrix for camera manipulation
pragma( inline ) Matrix_4x4 lookAt( Vec4f eye, Vec4f center, Vec4f up )
{
	Vec4f l_forward = ( center - eye ).normalized();
	Vec4f l_right = l_forward.crossProduct( up ).normalized();
	Vec4f l_up = l_right.crossProduct( l_forward );

	// Matrix magic
	float[][] m = [[l_right.x, l_right.y, l_right.z, -eye.x],
				   [l_up.x, l_up.y, l_up.z, -eye.y],
				   [-l_forward.x, -l_forward.y, -l_forward.z, -eye.z],
				   [0.0f, 0.0f, 0.0f, 1.0f]];

	return new Matrix_4x4( m );
}

// Rotate about the x-axis
pragma( inline ) Matrix_4x4 initRotateX( float angle )
{
	float sinf = sin( angle );
	float cosf = cos( angle );

	float[][] m = [[1.0f, 0.0f, 0.0f, 0.0f], 
				   [0.0f, cosf, -sinf, 0.0f], 
				   [0.0f, sinf, cosf, 0.0f], 
				   [0.0f, 0.0f, 0.0f, 1.0f]];

	return new Matrix_4x4( m );
}

// Rotate about the y-axis
pragma( inline ) Matrix_4x4 initRotateY( float angle )
{
	float sinf = sin( angle );
	float cosf = cos( angle );

	float[][] m = [[cosf, 0.0f, -sinf, 0.0f], 
				   [0.0f, 1.0f, 0.0f, 0.0f], 
				   [sinf, 0.0f, cosf, 0.0f], 
				   [0.0f, 0.0f, 0.0f, 1.0f]];

	return new Matrix_4x4( m );
}

// Rotate about the z-axis
pragma( inline ) Matrix_4x4 initRotateZ( float angle )
{
	float sinf = sin( angle );
	float cosf = cos( angle );

	float[][] m = [[cosf, -sinf, 0.0f, 0.0f], 
				   [sinf, cosf, 0.0f, 0.0f], 
				   [0.0f, 0.0f, 0.0f, 1.0f],  
				   [0.0f, 0.0f, 0.0f, 1.0f]];

	return new Matrix_4x4( m );
}

// Rotate about an arbitrary axis defined as a vector
pragma( inline ) Matrix_4x4 initRotate( Vec4f axis, float angle )
{
	float sinf = sin( angle );
	float cosf = cos( angle );

	float[][] m = [[( axis.x * axis.x ) * ( 1.0f - cosf ) + cosf, ( axis.x * axis.y ) * ( 1 - cosf ) - ( axis.z * sinf ), ( axis.x * axis.z ) * ( 1.0f - cosf ) + ( axis.y * sinf ), 0.0f],
				   [( axis.x * axis.y ) * ( 1.0f - cosf ) + ( axis.z * sinf ), ( axis.y * axis.y ) * ( 1.0f - cosf ) + cosf, ( axis.y * axis.z ) * ( 1.0f - cosf ) - ( axis.x * sinf ), 0.0f],
				   [( axis.x * axis.z ) * ( 1.0f - cosf ) - ( axis.y * sinf ), ( axis.y * axis.z ) * ( 1.0f - cosf ) + ( axis.x * sinf ), ( axis.z * axis.z ) * ( 1.0f - cosf ) + cosf, 0.0f],
				   [0.0f, 0.0f, 0.0f, 1.0f]];

	return new Matrix_4x4( m );
}

// Initialize rotations on all three base axes and multiply them in the proper order
pragma( inline ) Matrix_4x4 initRotate( float angle_x, float angle_y, float angle_z )
{
	return initRotateZ( angle_z ) * ( initRotateY( angle_y ) * initRotateX( angle_x ) );
}

// Scale
pragma( inline ) Matrix_4x4 initScale( Vec4f vec )
{
	float[][] m = [[vec.x, 0.0f, 0.0f, 0.0f], 
				   [0.0f, vec.x, 0.0f, 0.0f], 
				   [0.0f, 0.0f, vec.z, 0.0f], 
				   [0.0f, 0.0f, 0.0f, 1.0f]];

	return new Matrix_4x4( m );
}

// Translate
pragma( inline ) Matrix_4x4 initTranslation( Vec4f vec )
{
	Matrix_4x4 matrix = identity();
	matrix[0, 3] = vec.x;
	matrix[1, 3] = vec.y;
	matrix[2, 3] = vec.z;

	return matrix;
}

// Matrix of our screen space
Matrix_4x4 viewportTransform( float halfWidth, float halfHeight )
{
	float[][] m = [[halfWidth, 0.0f, 0.0f, halfWidth], 
				   [0.0f, -halfHeight, 0.0f, halfHeight], 
				   [0.0f, 0.0f, 1.0f, 0.0f], 
				   [0.0f, 0.0f, 0.0f, 1.0f]];

	return new Matrix_4x4( m );
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
