//=============================================================================
//
// Purpose: Graphical window where images are presented and updated
//
//=============================================================================

module window;

import rasterizer;
import derelict.sdl2.sdl;
import std.stdio;
import std.string;

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
		window = SDL_CreateWindow( title, SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, width, height, flags );
		renderer = SDL_CreateRenderer( window, -1, SDL_RendererFlags.SDL_RENDERER_SOFTWARE );
		surface = SDL_GetWindowSurface(window);

		if ( !window )
		{
			writeln( stderr, "Failed to initialize: %s\n", SDL_GetError() );
			return false;
		}

		rasterizer = new Rasterizer( width, height );

		return true;
	}

	// Call this when we're ready to kill the window
	void quit()
	{
		SDL_FreeSurface( surface );
		SDL_DestroyRenderer( renderer );
		SDL_DestroyWindow( window );
		SDL_Quit();
	}

	void update()
	{
		SDL_UpdateWindowSurface( window );

		deltaTime = SDL_GetTicks() - startTime;
		startTime = SDL_GetTicks();
		SDL_SetWindowTitle( window, toStringz( format( "%s%d", "FPS: ", 1000 / deltaTime ) ) );
	}

	void lockSurface() 
	{
		SDL_FillRect( surface, null, 0 );
		SDL_LockSurface( surface );
	}

	void unlockSurface()
	{
		SDL_UnlockSurface( surface );
	}

	Rasterizer getRasterizer() { return rasterizer; }
	SDL_Window *getWindow() { return window; }
	SDL_Surface *getSurface() { return surface; }

private:
	SDL_Renderer *renderer = null;
	SDL_Window *window = null;
	SDL_Surface* surface;
	Rasterizer rasterizer;
	int height = 640;
	int width = 480;
	const char *title = "Window";
	SDL_WindowFlags flags = SDL_WINDOW_SHOWN;

	// FPS counter
	uint startTime = 0;
	uint deltaTime = 0;

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