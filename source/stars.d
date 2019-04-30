//=============================================================================
//
// Purpose: 3D stars demo of perspective manipulation on a 2D plane
//
//=============================================================================

module stars;

import bitmap;
import point;
import std.random;
import std.math;

class StarDemo
{
public:
	this( int starCount, float speed, float spread, float fov )
	{
		this.speed = speed;
		this.spread = spread;
		this.fovRadians = this.toRadians( fov );
		stars = new Point[starCount];

		foreach( int i; 0 .. stars.length )
		{
			init( i );
		}
	}

	void update( Bitmap bmp, float change )
	{
		bmp.fill( cast(byte)0x00 );

		float halfW = bmp.getWidth() / 2.0f;
		float halfH = bmp.getHeight() / 2.0f;
		foreach( int i; 0 .. stars.length )
		{
 			stars[i].z -= change * speed;

			// Current star has gone too far, reinit.
			if ( stars[i].z <= 0 )
			{
				init( i );
			}

			int x = cast( int )( ( stars[i].x / ( stars[i].z * tan( fovRadians / 2 ) ) ) * halfW + halfW );
			int y = cast( int )( ( stars[i].y / ( stars[i].z * tan( fovRadians / 2 ) ) ) * halfH + halfH );

			if ( x < 0 || x >= bmp.getWidth()
			  || y < 0 || y >= bmp.getHeight() )
			{
				// Current star is outside of the x/y plane, reinit.
				init( i );
			}
			else
			{
				bmp.draw( x, y, stars[i].color );
			}
		}
	}

private:
	void init( int index )
	{
		stars[index] = new Point();

		stars[index].x = ( uniform( 0.0f, 2.0f ) - 1 ) * spread; // range of -1 to 1 on x-plane
		stars[index].y = ( uniform( 0.0f, 2.0f ) - 1 ) * spread; // range of -1 to 1 on y-plane
		stars[index].z = ( uniform( 0.0f, 1.0f ) + 0.0001 ) * spread; // range of 0 to 1 on z-plane

		stars[index].color = Color(cast(byte)uniform( 0, 255 ), cast( byte )uniform( 0, 255 ), cast( byte )uniform( 0, 255 ), cast( byte )uniform( 0, 255 ) );
	}

	real toRadians( float theta )
	{
		return cast( real )( ( theta * PI ) / 180 );
	}

private:
	Point[] stars;
	const float speed;
	const float spread;
	const real fovRadians;
}