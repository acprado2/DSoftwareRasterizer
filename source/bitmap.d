//=============================================================================
//
// Purpose: Performs pixel manipulation on SDL surface
//
//=============================================================================

module bitmap;

import std.typecons;
import derelict.sdl2.sdl;

// tuple that stores base rgb values and the alpha of a pixel from 0-255
alias Color = Tuple!( ubyte, "r", ubyte, "g", ubyte, "b",  ubyte, "a" );

class Bitmap
{
public:
	this( int width, int height )
	{
		this.width = width;
		this.height = height;
	}

	void draw( int x, int y, Color c )
	{
		// Apparently alpha goes first in the pixel map for SDL
		uint color = cast( uint )( c.a << 24 |
								   c.r << 16 |
								   c.g << 8 |
								   c.b );
		if ( surface )
		{
			uint *ptr = cast( uint * )surface.pixels;
			int offset = y * ( surface.pitch / 4 );
			ptr[offset + x ] = cast( uint )( color );
		}
	}

	int getWidth() { return width; }
	int getHeight() { return height; }

	void setSurface( SDL_Surface* surface ) { this.surface = surface; }

private:
	const int width;
	const int height;
	SDL_Surface* surface;
}