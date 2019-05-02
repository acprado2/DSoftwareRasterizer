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

class Rasterizer: Bitmap
{
public:
	this( int width, int height )
	{
		super( width, height );
	}

	// draw a line given two vectors
	void drawLine( Vec4f vec1, Vec4f vec2 )
	{
		int x1 = cast( int )ceil( vec1.x );
		int x2 = cast( int )ceil( vec2.x );
		int y1 = cast( int )ceil( vec1.y );
		int y2 = cast( int )ceil( vec2.y );
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
		}

		dx = x2 - x1;
		dy = abs( y2 - y1 );
		int derror = 2 * dy;
		int error = 0;
		int y = y1;
		Color def = Color( cast (byte)0xFF, cast (byte)0xFF, cast (byte)0xFF, cast (byte)0xFF );

		for ( int x = x1; x <= x2; ++x )
		{
			// If we swapped axes earlier correct on draw
			bSwapAxes ? draw( y, x, def ) : draw( x, y, def );

			error += derror;
			if ( error > dx )
			{
				( y2 > y1 ) ? ++y : --y;
				error -= 2 * dx;
			}
		}
	}

	// draw a horizontal line between two x-coordinates given a y-pos
	void drawLineHorizontal( int x1, int x2, int ypos )
	{
		for ( int x = x1; x < x2; ++x )
		{
				draw( x, ypos, Color( cast (byte)0xFF, cast (byte)0x00, cast (byte)0x00, cast (byte)0xFF ) );
		}
	}

	void drawTriangle( Vec4f vec1, Vec4f vec2, Vec4f vec3, bool bWireframe = false )
	{
		// Map our triangle to screen space
		Matrix_4x4 viewport = viewportTransform( getWidth() / 2.0f, getHeight() / 2.0f );

		// NOTE: positive w = not actually on screen (weird screen wrapping thing)
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
								   viewport.transform( vec3 ).perspectiveDivide() );
			}
			else
			{
				triangle( viewport.transform( vec1 ).perspectiveDivide(),
						  viewport.transform( vec2 ).perspectiveDivide(),
						  viewport.transform( vec3 ).perspectiveDivide() );
			}
		}
	}

private:
	// Helper method for drawWireframeTriangle
	void wireframeTriangle( Vec4f vec1, Vec4f vec2, Vec4f vec3 )
	{
		// Sort vectors by y-pos (lowest to highest)
		if ( vec1.y > vec2.y ) { swap( vec1, vec2 ); }
		if ( vec2.y > vec3.y ) { swap( vec2, vec3 ); }
		if ( vec1.y > vec2.y ) { swap( vec1, vec2 ); }

		drawLine( vec1, vec3 );
		drawLine( vec1, vec2 );
		drawLine( vec2, vec3 );
	}

	// Helper method for drawTriangle
	void triangle( Vec4f vec1, Vec4f vec2, Vec4f vec3 )
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

		// left and right side based on handedness
		float[] left  = bHandedness ? interpolate( vec1.x, vec1.y, vec2.x, vec2.y ) : interpolate( vec1.x, vec1.y, vec3.x, vec3.y );
		float[] right = bHandedness ? interpolate( vec1.x, vec1.y, vec3.x, vec3.y ) : interpolate( vec1.x, vec1.y, vec2.x, vec2.y );
		int count = -1;

		// Iterate through top triangle and draw scanlines
		foreach( i; 0 .. cast( int )ceil( vec2.y - vec1.y ) )
		{
			drawLineHorizontal( cast( int )ceil( left[i] ), cast( int )ceil( right[i] ), cast( int )ceil( vec1.y + i ) );

			// Track step position so we can draw the bottom triangle later
			++count;
		}

		// switch out the left or right depending on the handedness
		bHandedness ? ( left = interpolate( vec2.x, vec2.y, vec3.x, vec3.y ) ) : ( right = interpolate( vec2.x, vec2.y, vec3.x, vec3.y ) );

		// Iterate through bottom triangle and draw scanlines
		foreach( i; 0 .. cast( int )ceil( vec3.y - vec2.y ) )
		{
			drawLineHorizontal( cast( int )ceil( left[bHandedness ? i : count + i] ), cast( int )ceil( right[bHandedness ? count + i : i] ), cast( int )ceil( vec2.y + i ) );
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