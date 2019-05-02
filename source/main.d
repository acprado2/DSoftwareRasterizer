module main;

import vector;
import window;
import bitmap;
import vector;
import rasterizer;
import matrix;
import input;
import derelict.sdl2.sdl;
import std.stdio;

// Window dimensions (fixed for the time being)
enum WIDTH = 1200;
enum HEIGHT = 800;
enum DEPTH = 255;
enum SENSITIVITY = 0.25f;
enum MOVEMENT_SPEED = 2.0f;

int main( string[] args )
{
	DerelictSDL2.load();

	Window w = new Window( "Software Rendering Demo", HEIGHT, WIDTH, SDL_WindowFlags.SDL_WINDOW_SHOWN );

	if ( w.create() )
	{
		SDL_SetRelativeMouseMode( SDL_TRUE );
		SDL_ShowCursor( SDL_DISABLE );

		// Main program loop where we check when the program should terminate. Will be relocated later.
		bool bRunning = true;
		SDL_Event event;
		Rasterizer rasterizer = w.getRasterizer();
		
		// Track keyboard events
		InputHandler handler = new InputHandler();

		float deltaTime = 0.0f;
		float prevTime = 0.0f;
		float pitch = 0.0f;
		float yaw = 0.0f;

		// C U B E
		triangle[12] list;
		list[0].vertices[0] = new Vec4f( -0.2f, -0.2f, 1.0f);
		list[0].vertices[1] = new Vec4f( -0.2f, 0.4f, 1.0f);
		list[0].vertices[2] = new Vec4f( 0.4f, 0.4f, 1.0f);
		list[1].vertices[0] = new Vec4f( -0.2f, -0.2f, 1.0f);
		list[1].vertices[1] = new Vec4f( 0.4f, 0.4f, 1.0f);
		list[1].vertices[2] = new Vec4f( 0.4f, -0.2f, 1.0f);
		list[2].vertices[0] = new Vec4f( 0.4f, -0.2f, 1.0f);
		list[2].vertices[1] = new Vec4f( 0.4f, 0.4f, 1.0f);
		list[2].vertices[2] = new Vec4f( 0.4f, 0.4f, 1.4f);
		list[3].vertices[0] = new Vec4f( 0.4f, -0.2f, 1.0f);
		list[3].vertices[1] = new Vec4f( 0.4f, 0.4f, 1.4f);
		list[3].vertices[2] = new Vec4f( 0.4f, -0.2f, 1.4f);
		list[4].vertices[0] = new Vec4f( 0.4f, -0.2f, 1.4f);
		list[4].vertices[1] = new Vec4f( 0.4f, 0.4f, 1.4f);
		list[4].vertices[2] = new Vec4f( -0.2f, 0.4f, 1.4f);
		list[5].vertices[0] = new Vec4f( 0.4f, -0.2f, 1.4f);
		list[5].vertices[1] = new Vec4f( -0.2f, 0.4f, 1.4f);
		list[5].vertices[2] = new Vec4f( -0.2f, -0.2f, 1.4f);
		list[6].vertices[0] = new Vec4f( -0.2f, -0.2f, 1.4f);
		list[6].vertices[1] = new Vec4f( -0.2f, 0.4f, 1.4f);
		list[6].vertices[2] = new Vec4f( -0.2f, 0.4f, 1.0f);
		list[7].vertices[0] = new Vec4f( -0.2f, -0.2f, 1.4f);
		list[7].vertices[1] = new Vec4f( -0.2f, 0.4f, 1.0f);
		list[7].vertices[2] = new Vec4f( -0.2f, -0.2f, 1.0f);
		list[8].vertices[0] = new Vec4f( -0.2f, 0.4f, 1.0f);
		list[8].vertices[1] = new Vec4f( -0.2f, 0.4f, 1.4f);
		list[8].vertices[2] = new Vec4f( 0.4f, 0.4f, 1.4f);
		list[9].vertices[0] = new Vec4f( -0.2f, 0.4f, 1.0f);
		list[9].vertices[1] = new Vec4f( 0.4f, 0.4f, 1.4f);
		list[9].vertices[2] = new Vec4f( 0.4f, 0.4f, 1.0f);
		list[10].vertices[0] = new Vec4f( 0.4f, -0.2f, 1.4f);
		list[10].vertices[1] = new Vec4f( -0.2f, -0.2f, 1.4f);
		list[10].vertices[2] = new Vec4f( -0.2f, -0.2f, 1.0f);
		list[11].vertices[0] = new Vec4f( 0.4f, -0.2f, 1.4f);
		list[11].vertices[1] = new Vec4f( -0.2f, -0.2f, 1.0f);
		list[11].vertices[2] = new Vec4f( 0.4f, -0.2f, 1.0f);

		// Camera
		Vec4f eye = new Vec4f( 0.0f, 0.0f, 0.0f );
		Vec4f up = new Vec4f( 0.0f, 1.0f, 0.0f );

		Matrix_4x4 projection = perspective( degreesToRadians( 70.0f ), cast( float )WIDTH / HEIGHT, 0.1f, DEPTH );

		// Map our triangle to screen space
		Matrix_4x4 viewport = viewportTransform( WIDTH / 2.0f, HEIGHT / 2.0f );

		while ( bRunning )
		{
			// Flush the screen
			rasterizer.fill( cast(byte)0x00 );

			float flTime = SDL_GetTicks() / 1000.0f;
			float deg = ( flTime ) % 360;
			deltaTime = flTime - prevTime;
			prevTime = flTime;

			// Poll window events
			while ( SDL_PollEvent( &event ) != 0 )
			{
				switch ( event.type )
				{
					case SDL_QUIT:
						bRunning = false;
						break;

					case SDL_MOUSEMOTION:
						pitch -= event.motion.yrel * SENSITIVITY;
						yaw -= event.motion.xrel * SENSITIVITY;
						
						SDL_WarpMouseInWindow( w.getWindow(), WIDTH / 2, HEIGHT / 2 );
						break;

					default:
						break;
				}
			}

			SDL_PumpEvents();

			// Handle keyboard events
			// FPS controls
			float speed = MOVEMENT_SPEED * deltaTime;

			if ( handler.isPressed( SDL_GetScancodeFromKey( SDLK_a ) ) ) { eye.x += speed; }
			if ( handler.isPressed( SDL_GetScancodeFromKey( SDLK_d ) ) ) { eye.x -= speed; }
			if ( handler.isPressed( SDL_GetScancodeFromKey( SDLK_w ) ) ) { eye.z -= speed; }
			if ( handler.isPressed( SDL_GetScancodeFromKey( SDLK_s ) ) ) { eye.z += speed; }

			// up, down, left, right camera translations
			if ( handler.isPressed( SDL_GetScancodeFromKey( SDLK_UP ) ) )    { eye.y -= speed; }
			if ( handler.isPressed( SDL_GetScancodeFromKey( SDLK_DOWN ) ) )  { eye.y += speed; }
			if ( handler.isPressed( SDL_GetScancodeFromKey( SDLK_LEFT ) ) )  { eye.x += speed; }
			if ( handler.isPressed( SDL_GetScancodeFromKey( SDLK_RIGHT ) ) ) { eye.x -= speed; }

			// Close the program on escape
			if ( handler.isPressed( SDL_GetScancodeFromKey( SDLK_ESCAPE ) ) ) { bRunning = false; }

			// Invest in quaternions at some point
			Matrix_4x4 mCameraRotation = initRotateY( degreesToRadians( yaw ) ) * initRotateX( degreesToRadians( pitch ) );

			Vec4f target = new Vec4f( 0.0f, 0.0f, 1.0f, 0.0f );
			target = eye + mCameraRotation.transform( target );// + mCameraRotation.transform( target );
			Matrix_4x4 view = lookAt( eye, target, up );

			// Model matrix
			Matrix_4x4 t = initTranslation( new Vec4f( 0.0f, 0.0f, 3.0f ) );
			Matrix_4x4 t2 = initTranslation( new Vec4f( 1.0, 0.0f, 2.0f ) );
			//Matrix_4x4 r = initRotate( degreesToRadians( deg * 30 ), degreesToRadians( deg * 30 ), degreesToRadians( deg * 30 ) );
			Matrix_4x4 r = identity();
			Matrix_4x4 s = initScale( new Vec4f( 1.0f, 1.0f, 1.0f ) );
			Matrix_4x4 model = t * r * s;

			Matrix_4x4 model2 = t2 * r * s;

			foreach ( i; 0 .. list.length )
			{
				Vec4f vec1 = list[i].vertices[0];
				Vec4f vec2 = list[i].vertices[1];
				Vec4f vec3 = list[i].vertices[2];

				rasterizer.drawTriangle( ( viewport * ( projection * ( view * model ) ) ).transform( vec1 ),
										 ( viewport * ( projection * ( view * model ) ) ).transform( vec2 ),
										 ( viewport * ( projection * ( view * model ) ) ).transform( vec3 ), true );

				rasterizer.drawTriangle( ( viewport * ( projection * ( view * model2 ) ) ).transform( vec1 ),
										 ( viewport * ( projection * ( view * model2 ) ) ).transform( vec2 ),
										 ( viewport * ( projection * ( view * model2) ) ).transform( vec3 ), true );

				/*if ( i == 2 )
				{
					rasterizer.drawTriangle( ( viewport * ( projection * ( view * model ) ) ).transform( vec1 ),
											 ( viewport * ( projection * ( view * model ) ) ).transform( vec2 ),
											 ( viewport * ( projection * ( view * model ) ) ).transform( vec3 ) );
				}*/

				/*vec1 = model.transform( vec1 );
				vec1 = view.transform( vec1 );
				vec1 = projection.transform( vec1 );
				vec1 = viewport.transform( vec1 );

				vec2 = model.transform( vec2 );
				vec2 = view.transform( vec2 );
				vec2 = projection.transform( vec2 );
				vec2 = viewport.transform( vec2 );

				vec3 = model.transform( vec3 );
				vec3 = view.transform( vec3 );
				vec3 = projection.transform( vec3 );
				vec3 = viewport.transform( vec3 );

				rasterizer.drawTriangle( vec1,
										 vec2,
										 vec3, true );*/
			}
			w.update();
		}

		w.quit();
	}
	return 0;
}

struct triangle
{
	Vec4f[3] vertices;
}