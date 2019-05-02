//=============================================================================
//
// Purpose: Input management class for key presses during program run
//
//=============================================================================

module input;

import derelict.sdl2.sdl;

class InputHandler
{
public:
	this() 
	{ 
		keystates = SDL_GetKeyboardState( null );
	}

	bool isPressed( SDL_Scancode key ) { return keystates[key] == SDL_PRESSED; }
	bool isReleased( SDL_Scancode key ) { return keystates[key] == SDL_RELEASED; }

private:
	const ubyte *keystates;
}