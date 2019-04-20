module point;

import bitmap;
import vector;
import std.stdio;

class Point
{
public:
	// Describes the position of the point on a plane
	float x, y, z;
	Color color;

	// Constructors and destructors
	this() { this( 0, 0, 0 ); }
	this( float x, float y, float z = 0 ) 
	{
		this.x = x;
		this.y = y;
		this.z = z;
		color = Color( cast( byte )0xFF, cast( byte )0xFF, cast( byte )0xFF, cast( byte )0xFF );
	}

	this ( float x, float y, float z, Color c )
	{
		this.x = x;
		this.y = y;
		this.z = z;
		color = c;
	}

	~this() {}

	// Arithmetic methods
	Point addVecToPoint( Vector vec ) { return new Point( this.x + vec.x, this.y + vec.y, this.z + vec.z ); }
	Point subtractVecFromPoint( Vector vec ) { return new Point( this.x - vec.x, this.y - vec.y, this.z - vec.z ); }
	Vector subtractPointFromPoint( Point p ) { return new Vector( this.x - p.x, this.y - p.y, this.z - p.z ); }
}