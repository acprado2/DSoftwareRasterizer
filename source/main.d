module main;

import vector;
import point;
import window;
import bitmap;
import stars;
import derelict.sdl2.sdl;
import std.stdio;
import std.datetime.stopwatch;

// Window dimensions (fixed for the time being)
static immutable WIDTH = 1600;
static immutable HEIGHT = 900;

int main( string[] args )
{
	DerelictSDL2.load();

	Window w = new Window( "Software Rendering Demo", HEIGHT, WIDTH, SDL_WindowFlags.SDL_WINDOW_SHOWN );

	if ( w.create() )
	{
		// Main program loop where we check when the program should terminate. Will be relocated later.
		bool bRunning = true;
		SDL_Event event;
		Bitmap bmp = w.getBitMap();

		StarDemo stars = new StarDemo( 8192, 20.0f, 40.0f );

		StopWatch sw;
		sw.start();

		while ( bRunning )
		{
			// Poll window events
			while ( SDL_PollEvent( &event ) != 0 )
			{
				if ( event.type == SDL_QUIT )
					bRunning = false;
			}

			// Calculate the time that has elapsed between frames
			long curTime = sw.peek().total!"nsecs";
			float change = cast( float )( curTime / 1000000000.0 );

			stars.update( bmp, change );
			w.update();

			sw.reset();
		}

		w.quit();
	}
	return 0;
}
