module main;

import vector;
import window;
import bitmap;
//import stars;
import vector;
import rasterizer;
import matrix;
import derelict.sdl2.sdl;
import std.stdio;
import std.datetime.stopwatch;

// Window dimensions (fixed for the time being)
static immutable WIDTH = 1200;
static immutable HEIGHT = 800;

int main( string[] args )
{
	DerelictSDL2.load();

	Window w = new Window( "Software Rendering Demo", HEIGHT, WIDTH, SDL_WindowFlags.SDL_WINDOW_SHOWN );

	if ( w.create() )
	{
		// Main program loop where we check when the program should terminate. Will be relocated later.
		bool bRunning = true;
		SDL_Event event;
		Rasterizer rasterizer = w.getRasterizer();

		/*StopWatch sw;
		sw.start();

		Bitmap bmp = cast( Bitmap )rasterizer;
		StarDemo stars = new StarDemo( 4096, 16.0f, 40.0f, 110.0f );

		while ( bRunning )
		{
			// Poll window events
			while ( SDL_PollEvent( &event ) != 0 )
			{
				if ( event.type == SDL_QUIT )
					bRunning = false;
			}

			// Calculate the time that has elapsed between frames
			long curTime = sw.peek().total!"msecs";
			float change = cast( float )( curTime / 1000.0f );
			sw.reset();

			stars.update( bmp, change );
			w.update();
		}*/

		Vec4f vec1 = new Vec4f( 0.0, 0.5, 1 );
		Vec4f vec2 = new Vec4f( -0.3, -0.2, 1 );
		Vec4f vec3 = new Vec4f( 0.5, 0.0, 1 );

		Matrix_4x4 projection = perspective( degreesToRadians( 110.0f ), cast( float )WIDTH/HEIGHT, 0.1f, 1000.0f );

		while ( bRunning )
		{
			// Poll window events
			while ( SDL_PollEvent( &event ) != 0 )
			{
				if ( event.type == SDL_QUIT )
					bRunning = false;
			}

			rasterizer.fill( cast(byte)0xFF );

			float deg = ( SDL_GetTicks() / 1000.0f ) % 360;

			Matrix_4x4 mat = projection.rotate( new Vec4f( 0.5f, 0.01f, 1.0f ), degreesToRadians( deg * 30 ) );
			rasterizer.drawTriangle( mat.transform( vec1 ), mat.transform( vec2 ), mat.transform( vec3 ) );
			rasterizer.drawTriangle( mat.transform( vec1 ), mat.transform( vec2 ), mat.transform( vec3 ), true );
			//rasterizer.drawTriangle( vec1, vec2, vec3 );

			w.update();
		}

		w.quit();
	}
	return 0;
}
