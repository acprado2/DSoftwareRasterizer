module point;

import bitmap;
import vector;
import std.stdio;

// TODO: Rework and possibly remove this class
class Point
{
public:
	// Describes the position of the point on a plane
	float x, y, z;
	Color color;

	// Constructors and destructors
	this() { this( 0.0f, 0.0f, 0.0f ); }
	this( float x, float y, float z = 0.0f ) 
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
	Point addVecToPoint( Vec4f vec ) { return new Point( this.x + vec.x, this.y + vec.y, this.z + vec.z ); }
	Point addVecToPoint( Vec3f vec ) { return new Point( this.x + vec.x, this.y + vec.y, this.z + vec.z ); }
	Point addVecToPoint( Vec2f vec ) { return new Point( this.x + vec.x, this.y + vec.y, 0.0f ); }

	Point subtractVecFromPoint( Vec4f vec ) { return new Point( this.x - vec.x, this.y - vec.y, this.z - vec.z ); }
	Point subtractVecFromPoint( Vec3f vec ) { return new Point( this.x - vec.x, this.y - vec.y, this.z - vec.z ); }
	Point subtractVecFromPoint( Vec2f vec ) { return new Point( this.x - vec.x, this.y - vec.y, 0.0f ); }

	Vec4f subtractPointFromPoint4D( Point p ) { return new Vector4D( this.x - p.x, this.y - p.y, this.z - p.z, 0.0f ); }
	Vec3f subtractPointFromPoint3D( Point p ) { return new Vec3f( this.x - p.x, this.y - p.y, this.z - p.z ); }
	Vec2f subtractPointFromPoint2D( Point p ) { return new Vec2f( this.x - p.x, this.y - p.y, ); }
}