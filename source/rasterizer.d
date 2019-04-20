module rasterizer;

import bitmap;
import vector;
import point;
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
	void drawLine( Point p1, Point p2, int bufferOffset )
	{
		int x1 = cast( int )p1.x;
		int x2 = cast( int )p2.x;
		int y1 = cast( int )p1.y;
		int y2 = cast( int )p2.y;
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

		for ( int x = x1; x <= x2; ++x )
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

	// Draw a triangle given three vertices
	void drawTriangle( Point p1, Point p2, Point p3 )
	{
		// Sort vertices by y-pos (lowest to highest)
		if ( p1.y > p2.y ) { swap( p1, p2 ); }
		if ( p2.y > p3.y ) { swap( p2, p3 ); }
		if ( p1.y > p2.y ) { swap( p1, p2 ); }

		// Get two vectors from our three points
		Vector v1 = p3.subtractPointFromPoint( p1 );
		Vector v2 = p2.subtractPointFromPoint( p1 );

		// Determine if the triangle is left-hand or right-hand using the area
		int offset = v1.crossProduct2D( v2 ) >= 0 ? 1 : 0;

		drawLine( p1, p3, offset );
		drawLine( p1, p2, 1 - offset );
		drawLine( p2, p3, 1 - offset );
		fillShape( cast( int )p1.y, cast( int )p3.y );
	}

	// Fill in a shape from our scan buffer
	void fillShape( int yMin, int yMax )
	{
		for ( int i = yMin; i < yMax; ++i )
		{
			for ( int j = scanBuffer[i * 2]; j <= scanBuffer[i * 2 + 1]; ++j )
			{
				draw( j, i, Color( cast (byte)0xFF, cast (byte)0xFF, cast (byte)0xFF, cast (byte)0xFF ) );
			}
		}
	}

private:
	// Buffer that contains min and max x positions for shape to be filled
	int[] scanBuffer;
}