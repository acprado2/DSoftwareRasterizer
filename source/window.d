module window;

import bitmap;
import derelict.sdl2.sdl;
import std.stdio;

class Window
{
public:
	this() { this( title, height, width, flags ); }
	this( const char *windowTitle, int height, int width, SDL_WindowFlags flags )
	{
		this.title = windowTitle;
		this.height = height;
		this.width = width;
		this.flags = flags;
	}

	// Create a new window
	bool create()
	{
		if ( SDL_Init( SDL_INIT_VIDEO ) < 0 ) 
		{ 
			writeln( stderr, "Failed to initialize: %s\n", SDL_GetError() );
			return false;
		}

		// Create new window at the center of the screen
		window = SDL_CreateWindow( title, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, flags );
		renderer = SDL_CreateRenderer( window, -1, SDL_RendererFlags.SDL_RENDERER_SOFTWARE );

		if ( !window )
		{
			writeln( stderr, "Failed to initialize: %s\n", SDL_GetError() );
			return false;
		}

		bmp = new Bitmap( height, width );

		return true;
	}

	// Call this when we're ready to kill the window
	void quit()
	{
		SDL_FreeSurface( surface );
		SDL_DestroyWindow( window );
		SDL_Quit();
	}

	void update()
	{
		SDL_DestroyTexture( tex );
		SDL_FreeSurface( surface );
		SDL_RenderClear( renderer );

		//draw a random pixel every update 
		//bmp.draw( uniform(0, width), uniform(0, height), Color(cast(byte)uniform(0, 255), cast(byte)uniform(0, 255), cast(byte)uniform(0, 255), cast(byte)uniform(0, 255) ) );

		surface = SDL_CreateRGBSurfaceFrom( cast( void* )bmp.map, width, height, 32, width * 4, rmask, gmask, bmask, amask );
		tex = SDL_CreateTextureFromSurface( renderer, surface );

		SDL_RenderCopy( renderer, tex, null, null );
		SDL_RenderPresent( renderer );

		SDL_UpdateWindowSurface( window );
	}

	Bitmap getBitMap() { return bmp; }

private:
	SDL_Texture *tex = null;
	SDL_Renderer *renderer = null;
	SDL_Window *window = null;
	SDL_Surface *surface = null;
	Bitmap bmp;
	int height = 640;
	int width = 480;
	const char *title = "Window";
	SDL_WindowFlags flags = SDL_WINDOW_SHOWN;

	// Check if the system uses big or little endian so rbga masks work as intended
	version ( BigEndian )
	{
		Uint32 rmask = 0xff000000,
			   gmask = 0x00ff0000,
			   bmask = 0x0000ff00,
			   amask = 0x000000ff;
	}
	else
	{
		Uint32 rmask = 0x000000ff,
			   gmask = 0x0000ff00,
			   bmask = 0x00ff0000,
			   amask = 0xff000000;
	}
}