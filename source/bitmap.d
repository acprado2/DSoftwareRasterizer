module bitmap;

import std.typecons;

// tuple that stores base rgb values and the alpha of a pixel from 0-255
alias Color = Tuple!( byte, "r", byte, "g", byte, "b",  byte, "a" );

class Bitmap
{
public:
	this( int width, int height )
	{
		this.width = width;
		this.height = height;
		map = new byte[width * height * 4];
	}

	// Single-shade fill method
	void fill( byte shade )
	{
		// Fill the rgba values of each pixel with the specified shade
		foreach( i; 0 .. map.length )
		{
			map[i] = shade;
		}
	}

	// Higher-precision fill method
	void fill( Color c )
	{
		// Fill each pixel with the specified color
		for( int i = 0; i < map.length; i += 4 )
		{
			map[i] = c.r;
			map[i + 1] = c.g;
			map[i + 2] = c.b;
			map[i + 3] = c.a;
		}
	}

	void draw( int x, int y, Color c )
	{
		// Position of pixel to draw
		int pos = ( x + ( y * width ) ) * 4;
		map[pos] = c.r;
		map[pos + 1] = c.g;
		map[pos + 2] = c.b;
		map[pos + 3] = c.a;
	}

	int getWidth() { return width; }
	int getHeight() { return height; }
	byte[] getFrameBuffer() { return map; }

private:
	byte[] map;
	const int width;
	const int height;
}