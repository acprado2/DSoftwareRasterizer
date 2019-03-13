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
	this( float x, float y, float z ) 
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}
	~this() {}

	// Arithmetic methods
	Point addVecToPoint( Vector vec ) { return new Point( this.x + vec.x, this.y + vec.y, this.z + vec.z ); }
	Point subtractVecFromPoint( Vector vec ) { return new Point( this.x - vec.x, this.y - vec.y, this.z - vec.z ); }
	Vector subtractPointFromPoint( Point p ) { return new Vector( this.x - p.x, this.y - p.y, this.z - p.z ); }

	// Dummy method
	void drawPoint()
	{
		writeln( "DRAWPOINT: (", x, ",", y, ",", z, ")");
	}

}