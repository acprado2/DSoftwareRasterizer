//=============================================================================
//
// Purpose: Vector classes for graphical representation
//
//=============================================================================

module vector;

import std.math;

alias Vec2f = Vector2D!(float);
alias Vec2i = Vector2D!(int);
alias Vec3f = Vector3D!(float);
alias Vec3i = Vector3D!(int);
alias Vec4f = Vector4D;

class Vector2D(T)
{
public:
	// Describes the length of the vector relative to a point of origin
	T x, y;

	// Constructors and destructors
	this( T x, T y ) 
	{
		this.x = x;
		this.y = y;
	}

	~this() {}

	// Arithmetic methods
	Vector2D add( Vector2D!(T) vec ) { return new Vector2D( this.x + vec.x, this.y + vec.y ); }
	Vector2D subtract( Vector2D!(T) vec ) { return new Vector2D( this.x - vec.x, this.y - vec.y ); }

	T dotProduct( Vector2D!(T) vec ) { return ( this.x * vec.x + this.y * vec.y ); }
	T crossProduct( Vector2D!(T) vec ) { return ( this.x * vec.y - this.y * vec.x ); }

	float Length() { return sqrt( cast( float )( x * x + y * y ) ); }

	T LengthSqr() { return ( x * x + y * y ); } // Use this if we don't care about the exact value of the magnitude (faster)

	// Operator overloading
	Vector2D!(T) opBinary( string op )( Vector2D!(T) vec )
	{
		return mixin( "new Vector2D( this.x "~op~" vec.x, this.y "~op~" vec.y ) " );
	}
}

class Vector3D(T)
{
public:
	// Describes the length of the vector relative to a point of origin
	T x, y, z;

	// Constructors and destructors
	this( T x, T y, T z ) 
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}

	~this() {}

	// Arithmetic methods
	Vector3D add( Vector3D!(T) vec ) { return new Vector3D( this.x + vec.x, this.y + vec.y, this.z + vec.z ); }
	Vector3D subtract( Vector3D!(T) vec ) { return new Vector3D( this.x - vec.x, this.y - vec.y, this.z - vec.z ); }

	T dotProduct( Vector3D!(T) vec ) { return ( this.x * vec.x + this.y * vec.y + this.z * vec.z ); }
	Vector3D crossProduct( Vector3D!(T) vec ) 
	{ 
		T x, y, z;
		x = this.y * vec.z - this.z * vec.y;
		y = this.z * vec.x - this.x * vec.z;
		z = this.x * vec.y - this.y * vec.x;
		return new Vector3D( x, y, z );
	}

	float Length() { return sqrt( cast( float )( x * x + y * y + z * z ) ); }
	T LengthSqr() { return ( x * x + y * y + z * z ); } // Use this if we don't care about the exact value of the magnitude (faster)

	void normalizeInPlace() 
	{
		float len = Length();
		x = cast( T )( x / len );
		y = cast( T )( y / len );
		z = cast( T )( z / len );
	}

	Vector3D!(T) normalized()
	{
		float len = Length();
		return new Vector3D( cast( T )( x / len ), cast( T )( y / len ), cast( T )( z / len ) );
	}

	// Operator overloading
	Vector3D!(T) opBinary( string op )( Vector3D!(T) vec )
	{
		return mixin( "new Vector2D( this.x "~op~" vec.x, this.y "~op~" vec.y, this.z "~op~" vec.z ) " );
	}
}

class Vector4D
{
public:
	// Describes the length of the vector relative to a point of origin
	float x, y, z, w;

	// Constructors and destructors
	this( float x, float y, float z, float w = 1.0f ) 
	{
		initialize( x, y, z, w );
	}

	~this() {}

	void initialize( float x, float y, float z, float w = 1.0f )
	{
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}

	void initialize( Vector4D vec )
	{
		this.x = vec.x;
		this.y = vec.y;
		this.z = vec.z;
		this.w = vec.w;
	}

	// Arithmetic methods
	void sub( Vector4D vec ) { this.initialize( this.x - vec.x, this.y - vec.y, this.z - vec.z, this.w - vec.w ); }

	float dotProduct( Vector4D vec ) { return ( this.x * vec.x + this.y * vec.y + this.z * vec.z + this.w * vec.w ); }

	Vector4D crossProduct( Vector4D vec ) 
	{ 
		float x, y, z;
		x = this.y * vec.z - this.z * vec.y;
		y = this.z * vec.x - this.x * vec.z;
		z = this.x * vec.y - this.y * vec.x;
		return new Vector4D( x, y, z, 0.0f );
	}

	void crossProductInPlace( Vector4D vec ) 
	{ 
		float x, y, z;
		x = this.y * vec.z - this.z * vec.y;
		y = this.z * vec.x - this.x * vec.z;
		z = this.x * vec.y - this.y * vec.x;
		this.initialize( x, y, z, 0.0f );
	}

	Vector4D perspectiveDivide() { return new Vector4D( x / w, y / w, z / w, w ); }

	float Length() { return sqrt( x * x + y * y + z * z + w * w ); }
	float LengthSqr() { return ( x * x + y * y + z * z + w * w ); } // Use this if we don't care about the exact value of the magnitude (faster)

	void normalizeInPlace() 
	{
		float len = Length();
		x = x / len;
		y = y / len;
		z = z / len;
		w = w / len;
	}

	Vector4D normalized()
	{
		float len = Length();
		return new Vector4D( x / len, y / len, z / len, w / len );
	}

	// Operator overloading
	Vector4D opBinary( string op )( Vector4D vec )
	{
		return mixin( "new Vector4D( this.x "~op~" vec.x, this.y "~op~" vec.y, this.z "~op~" vec.z, this.w "~op~" vec.w )" );
	}

	
	Vector4D opBinary( string op )( float val )
	{
		return mixin( "new Vector4D( this.x "~op~" val, this.y "~op~" val, this.z "~op~" val, this.w "~op~" val )" );
	}
}