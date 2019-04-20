module vector;

class Vector
{
public:
	// Describes the length of the vector relative to a point of origin
	float x, y, z;

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
	Vector add( Vector vec ) { return new Vector( this.x + vec.x, this.y + vec.y, this.z + vec.z ); }
	Vector subtract( Vector vec ) { return new Vector( this.x - vec.x, this.y - vec.y, this.z - vec.z ); }
	
	// Cross of 2D vectors returns magnitude
	float crossProduct2D( Vector vec ) { return ( ( this.x * vec.y ) - ( this.y * vec.x ) ); }
}
