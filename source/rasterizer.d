//=============================================================================
//
// Purpose: Specialized bitmap class where rasterization of world geometry is handled
//
//=============================================================================

module rasterizer;

import bitmap;
import vector;
import point;
import matrix;
import std.math;
import std.algorithm.mutation;

class Rasterizer: Bitmap
{
public:
	this( int width, int height )
	{
		super( width, height );
		scanBuffer = new int[2 * height];
	}

	// Load a line into the scan buffer. bufferOffset used for min/max of shape
	void drawLine( Vec4f vec1, Vec4f vec2, int bufferOffset )
	{
		int x1 = cast( int )vec1.x;
		int x2 = cast( int )vec2.x;
		int y1 = cast( int )vec1.y;
		int y2 = cast( int )vec2.y;
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

		for ( int x = x1; x < x2; ++x )
		{
			// Set color to the color of p1 for now
			// If we swapped axes earlier correct on draw
			//bSwapAxes ? draw( y, x, p1.color ) : draw( x, y, p1.color );
			if ( bSwapAxes ) 
			{
				scanBuffer[x * 2 + bufferOffset] = y; 
			}
			else
			{ 
				scanBuffer[y * 2 + bufferOffset] = x; 
			}

			error += derror;
			if ( error > dx )
			{
				( y2 > y1 ) ? ++y : --y;
				error -= 2 * dx;
			}
		}
	}

	void drawTriangle( Vec4f vec1, Vec4f vec2, Vec4f vec3 )
	{
		// Map our triangle to screen space
		Matrix_4x4 viewport = viewportTransform( getWidth() / 2.0f, getHeight() / 2.0f );

		// Draw triangle
		triangle( viewport.transform( vec1 ).perspectiveDivide(),
				  viewport.transform( vec2 ).perspectiveDivide(),
				  viewport.transform( vec3 ).perspectiveDivide() );
	}

	// Fill in a shape from our scan buffer
	void fillShape( int yMin, int yMax )
	{
		for ( int i = yMin; i < yMax; ++i )
		{
			for ( int j = scanBuffer[i * 2]; j < scanBuffer[i * 2 + 1]; ++j )
			{
				draw( j, i, Color( cast (byte)0xFF, cast (byte)0xFF, cast (byte)0xFF, cast (byte)0xFF ) );
			}
		}
	}

private:
	// Helper method for drawTriangle
	void triangle( Vec4f vec1, Vec4f vec2, Vec4f vec3 )
	{
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
		int offset = v1.crossProduct( v2 ) >= 0 ? 1 : 0;

		drawLine( vec1, vec3, offset );
		drawLine( vec1, vec2, 1 - offset );
		drawLine( vec2, vec3, 1 - offset );
		fillShape( cast( int )vec1.y, cast( int )vec3.y );
	}

	// Buffer that contains min and max x positions for shape to be filled
	int[] scanBuffer;
}