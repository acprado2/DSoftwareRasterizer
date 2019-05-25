//=============================================================================
//
// Purpose: Specialized bitmap class where rasterization of world geometry is handled
//
//=============================================================================

module rasterizer;

import bitmap;
import vector;
import matrix;
import std.math;
import std.algorithm.mutation;
import std.random;

enum COLOR_WHITE = Color( cast( byte )0xFF, cast( byte )0xFF, cast( byte )0xFF, cast( byte )0xFF );

class Rasterizer: Bitmap
{
public:
	this( int width, int height )
	{
		super( width, height );

		// z-buffer for depth checking
		z_buffer = new float[width * height];
		z_buffer[0 .. z_buffer.length] = 0.0f;
	}

	// draw a line given two vectors
	void drawLine( Vec4f vec1, Vec4f vec2, Color c  )
	{
		int x1 = cast( int )ceil( vec1.x );
		int x2 = cast( int )ceil( vec2.x );
		int y1 = cast( int )ceil( vec1.y );
		int y2 = cast( int )ceil( vec2.y );
		float z1 = vec1.z;
		float z2 = vec2.z;

		int dx = abs( x2 - x1 );
		int dy = abs( y2 - y1 );
		bool bSwapAxes = false;

		// If the y-axis covers more pixels than the x-axis we need to iterate over y instead of x
		if ( dy > dx )
		{
			swap( x1, y1 );
			swap( x2, y2 );
			bSwapAxes = true;
		}

		// Swap p1 and p2 if x2 is farther along the plane than x1
		if ( x1 > x2 )
		{
			swap( x1, x2 );
			swap( y1, y2 );
			swap( z1, z2 );
		}

		dx = x2 - x1;
		dy = abs( y2 - y1 );
		int derror = 2 * dy;
		int error = 0;
		int y = y1;

		// icky floating point math
		float step = ( ( 1.0f / z1 ) - ( 1.0f / z2 ) ) / dy;
		float z = z1;

		for ( int x = x1; x < x2; ++x )
		{
			int idx = bSwapAxes ? y + x * getWidth() : x + y * getWidth();
			// Check if z is closer to the screen than the current buffered z
			float idx_z = z_buffer[idx];
			if ( z > z_buffer[idx] )
			{
				// Update z-buffer
				z_buffer[idx] = z;

				// If we swapped axes earlier correct on draw
				bSwapAxes ? draw( y, x, c ) : draw( x, y, c );
			}

			z += step;
			error += derror;
			if ( error > dx )
			{
				( y2 > y1 ) ? ++y : --y;
				error -= 2 * dx;
			}
		}
	}

	// draw a horizontal line between two x-coordinates given a y-pos
	void drawLineHorizontal( int x1, int x2, int ypos, float z1, float z2, Color c )
	{
		float zStep = ( z2 - z1 ) / ( x2 - x1 );
		float z = z1;

		for ( int x = x1; x < x2; ++x )
		{
			int idx = x + ypos * getWidth();
			if ( z > z_buffer[idx] )
			{
				z_buffer[idx] = z;
				draw( x, ypos, c );
			}
			z += zStep;
		}
	}

	void drawTriangle( Vec4f vec1, Vec4f vec2, Vec4f vec3, Matrix_4x4 viewport, bool bWireframe = false, Color c = COLOR_WHITE )
	{

		// CULLING
		//float nearH = 2 * tan( FOV / 2 ) * 0.1, farH = 2 * tan( FOV / 2 ) * DEPTH;
		//float nearW = nearH * ( cast( float )WIDTH / HEIGHT ), farW = farH * ( cast( float )WIDTH / HEIGHT );

		// Draw triangle
		if ( isWithinFrustum( vec1) && isWithinFrustum( vec2 ) && isWithinFrustum( vec3 ) )
		{
			if ( bWireframe )
			{
				wireframeTriangle( viewport.transform( vec1 ).perspectiveDivide(),
								   viewport.transform( vec2 ).perspectiveDivide(),
								   viewport.transform( vec3 ).perspectiveDivide(), c );
			}
			else
			{
				triangle( viewport.transform( vec1 ).perspectiveDivide(),
						  viewport.transform( vec2 ).perspectiveDivide(),
						  viewport.transform( vec3 ).perspectiveDivide(), c );
			}
		}
	}

	void clearZBuffer()
	{
		z_buffer[0 .. z_buffer.length ] = 0.0f;
	}

private:
	// Helper method for drawWireframeTriangle
	void wireframeTriangle( Vec4f vec1, Vec4f vec2, Vec4f vec3, Color c )
	{
		// Sort vectors by y-pos (lowest to highest)
		if ( vec1.y > vec2.y ) { swap( vec1, vec2 ); }
		if ( vec2.y > vec3.y ) { swap( vec2, vec3 ); }
		if ( vec1.y > vec2.y ) { swap( vec1, vec2 ); }

		drawLine( vec1, vec3, c );
		drawLine( vec1, vec2, c );
		drawLine( vec2, vec3, c );
	}

	// Helper method for drawTriangle
	void triangle( Vec4f vec1, Vec4f vec2, Vec4f vec3, Color c )
	{
		// Dumb check for dumb triangles
		if ( ( vec1.x == vec2.x && vec1.y == vec2.y ) ||
			 ( vec1.x == vec3.x && vec1.y == vec3.y ) ||
			 ( vec2.x == vec3.x && vec2.y == vec3.y ) )
		{
			// This isn't a triangle
			return;
		}

		// Sort vectors by y-pos (lowest to highest)
		if ( vec1.y > vec2.y ) { swap( vec1, vec2 ); }
		if ( vec2.y > vec3.y ) { swap( vec2, vec3 ); }
		if ( vec1.y > vec2.y ) { swap( vec1, vec2 ); }

		// Get two temporary 2d vectors for handedness computation
		Vec2i v1 = new Vec2i( cast( int )vec3.x - cast( int )vec1.x, cast( int )vec3.y - cast( int )vec1.y, );
		Vec2i v2 = new Vec2i( cast( int )vec2.x - cast( int )vec1.x, cast( int )vec2.y - cast( int )vec1.y, );

		// Determine if the triangle is left-hand or right-hand using the area
		// NOTE: cross product gives us the area of the parallelogram spanning the vectors but to save 
		// computation cycles and because it doesn't matter for our purposes we don't divide this by 2
		bool bHandedness = v1.crossProduct( v2 ) >= 0 ? true : false;

		// In order to draw this triangle using horizontal lines we will cut the triangle into two triangles
		// at the horizontal line that intersects vec2 and the line between vec3 and vec1

		float[] left, right, z_left, z_right;
		// Use handedness to determine our linear interpolation arrays
		if ( bHandedness )
		{
			left  = interpolate( vec1.x, vec1.y, vec2.x, vec2.y );
			right = interpolate( vec1.x, vec1.y, vec3.x, vec3.y );
			z_left = interpolate( 1.0f / vec1.z, vec1.y, 1.0f / vec3.z, vec3.y);
			z_right = interpolate( 1.0f / vec1.z, vec1.y, 1.0f / vec3.z, vec3.y);
		}
		else
		{
			left  = interpolate( vec1.x, vec1.y, vec3.x, vec3.y );
			right = interpolate( vec1.x, vec1.y, vec2.x, vec2.y );
			z_left = interpolate( 1.0f / vec1.z, vec1.y, 1.0f / vec3.z, vec3.y);
			z_right = interpolate( 1.0f / vec1.z, vec1.y, 1.0f / vec2.z, vec2.y);
		}

		int count = -1;

		// Iterate through top triangle and draw scanlines
		for( int i = 0; i < cast( int )ceil( vec2.y - vec1.y ); ++i )
		{
			drawLineHorizontal( cast( int )ceil( left[i] ), cast( int )ceil( right[i] ), cast( int )ceil( vec1.y + i ), z_left[i], z_right[i], c );

			// Track step position so we can draw the bottom triangle later
			++count;
		}

		// switch out the left or right depending on the handedness
		if ( bHandedness )
		{
			left = interpolate( vec2.x, vec2.y, vec3.x, vec3.y );
			z_left = interpolate( 1.0f / vec2.z, vec2.y, 1.0f / vec3.z, vec3.y ); // Interpolate over 1/z (over z isn't linear)
		}
		else
		{
			right = interpolate( vec2.x, vec2.y, vec3.x, vec3.y );
			z_right = interpolate( 1.0f / vec2.z, vec2.y, 1.0f / vec3.z, vec3.y ); // Interpolate over 1/z (over z isn't linear)
		}

		// if we didn't loop earlier make sure we don't access illegal memory
		if ( count == -1 ) { ++count; }

		// Iterate through bottom triangle and draw scanlines
		for( int i = 0; i < cast( int )ceil( vec3.y - vec2.y ); ++i )
		{
			drawLineHorizontal( cast( int )ceil( left[bHandedness ? i : count + i] ), cast( int )ceil( right[bHandedness ? count + i : i] ), cast( int )ceil( vec2.y + i ), z_left[i], z_right[i], c );
		}
	}

	// Check is this vector is within the frustum (our viewing area)
	bool isWithinFrustum( Vec4f vec )
	{
		if ( abs( vec.x ) <= abs( vec.w ) && abs( vec.y ) <= abs( vec.w ) && abs( vec.z ) <= abs( vec.w ) )
		{
			return true;
		}

		return false;
	}

	float[] z_buffer;
}

// generate a list of coordinates interpolated along a line
float[] interpolate( float x1, float y1, float x2, float y2 )
{
	int dy = cast( int )ceil( y2 - y1 );
	float[] result = new float[dy];
	float step = ( x2 - x1 ) / result.length;
	float x = x1;

	for ( int y = 0; y < dy; ++y )
	{
		result[y] = x;
		x += step;
	}
	return result;
}