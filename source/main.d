module main;

import vector;
import window;
import bitmap;
import vector;
import rasterizer;
import matrix;
import input;
import mesh;
import derelict.sdl2.sdl;
import std.stdio;

// NOTE: Z-axis is reversed so the depth is really 0-(-255)
enum WIDTH = 1200;
enum HEIGHT = 800;
enum DEPTH = 255;
enum FOV = 110.0f;
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

		// Pass surface to rasterizer for pixel drawing
		rasterizer.setSurface( w.getSurface() );

		
		// Track keyboard events
		InputHandler handler = new InputHandler();

		float deltaTime = 0.0f;
		float prevTime = 0.0f;
		float pitch = 0.0f;
		float yaw = 0.0f;

		Mesh mesh = new Mesh( "2fort.obj" );

		// Camera
		Vec4f eye = new Vec4f( 0.0f, 0.0f, 0.0f );
		Vec4f up = new Vec4f( 0.0f, 1.0f, 0.0f );
		Vec4f look = new Vec4f( 0.0f, 0.0f, 0.0f );

		Matrix_4x4 projection = perspective( degreesToRadians( FOV ), cast( float )WIDTH / HEIGHT, 0.1f, DEPTH );

		while ( bRunning )
		{
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
			Vec4f fwd = look * speed;
			Vec4f right = fwd.crossProduct( up ).normalized() * speed;

			if ( handler.isPressed( SDL_GetScancodeFromKey( SDLK_a ) ) ) { eye = eye - right; }
			if ( handler.isPressed( SDL_GetScancodeFromKey( SDLK_d ) ) ) { eye = eye + right; }
			if ( handler.isPressed( SDL_GetScancodeFromKey( SDLK_w ) ) ) { eye = eye - fwd; }
			if ( handler.isPressed( SDL_GetScancodeFromKey( SDLK_s ) ) ) { eye = eye + fwd; }

			// up, down, left, right camera translations
			if ( handler.isPressed( SDL_GetScancodeFromKey( SDLK_UP ) ) )    { eye.y += speed; }
			if ( handler.isPressed( SDL_GetScancodeFromKey( SDLK_DOWN ) ) )  { eye.y -= speed; }
			if ( handler.isPressed( SDL_GetScancodeFromKey( SDLK_LEFT ) ) )  { eye.x += speed; }
			if ( handler.isPressed( SDL_GetScancodeFromKey( SDLK_RIGHT ) ) ) { eye.x -= speed; }

			// Close the program on escape
			if ( handler.isPressed( SDL_GetScancodeFromKey( SDLK_ESCAPE ) ) ) { bRunning = false; }

			// Invest in quaternions at some point
			Matrix_4x4 mCameraRotation = initRotateY( degreesToRadians( yaw ) ) * initRotateX( degreesToRadians( pitch ) );

			Vec4f target = new Vec4f( 0.0f, 0.0f, 1.0f, 0.0f );
			look = mCameraRotation.transform( target );
			target = eye + look;

			Matrix_4x4 view = lookAt( eye, target, up );

			// Model matrix
			Matrix_4x4 t = initTranslation( new Vec4f( 0.0f, -25.0f, -200.0f ) );
			//Matrix_4x4 r = initRotate( 0.0f, 0.0f, 0.0f );
			Matrix_4x4 r = identity();
			Matrix_4x4 s = initScale( new Vec4f( 1.0f, degreesToRadians( 90.0f ), 1.0f ) );
			Matrix_4x4 model = t * r * s;

			w.lockSurface();

			foreach ( tri; mesh.triangles )
			{
				Vec4f vec1 = ( projection * ( view * model ) ).transform( tri.vertices[0] );
				Vec4f vec2 = ( projection * ( view * model ) ).transform( tri.vertices[1] );
				Vec4f vec3 = ( projection * ( view * model ) ).transform( tri.vertices[2] );

				// Normal to the surface
				Vec4f normal = ( vec3 - vec1 ).crossProduct( vec2 - vec1 );
				normal.normalizeInPlace();

				if ( normal.dotProduct( model.transform( tri.vertices[0] ) - eye ) < 0.0f )
				{
					Vec4f light_dir = new Vec4f( 0.0f, 0.0f, 1.0f );
					float intensity = normal.dotProduct( light_dir );

					rasterizer.drawTriangle( vec1, vec2, vec3, false, Color( cast( ubyte )( intensity * 0xFF ), cast( ubyte )( intensity * 0xFF ), cast( ubyte )( intensity * 0xFF ), cast( ubyte )( 0xFF ) ) );
				}

				//rasterizer.drawTriangle( vec1, vec2, vec3, true );
			}

			w.unlockSurface();
			w.update();
			rasterizer.clearZBuffer();
		}

		w.quit();
	}
	return 0;
}