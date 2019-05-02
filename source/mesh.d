//=============================================================================
//
// Purpose: Simple class for parsing in .obj files as triangles we can render
//
//=============================================================================

module mesh;

import vector;
import std.stdio;
import std.container;
import std.conv;
import std.string;

class Mesh
{
	triangle[] triangles;

	this( string filename )
	{
		Array!Vec4f vertices;
		Array!string faces;

		foreach ( line ; File( filename ).byLine )
		{
			// Parse a vertice
			if ( !line.empty && line[0] == 'v' && line[1] == ' ' )
			{
				parse!char( line );
				line = line.stripLeft();
				auto x = parse!float( line );
				line = line.stripLeft();
				auto y = parse!float( line );
				line = line.stripLeft();
				auto z = parse!float( line );

				vertices.insert( new Vec4f( x, y, z ) );
			}

			// Parse a triangle
			if ( !line.empty && line[0] == 'f' )
			{
				parse!char( line );
				line = line.stripLeft();

				faces.insert( to!string( line ) );
			}
		}

		triangles = new triangle[faces.length];
		foreach ( i ; 0 .. faces.length )
		{
			string face = faces[i];
			triangles[i].vertices[0] = vertices[parse!int( face ) - 1];

			// Trash textures and normals for now 
			face = parseFaceElement( face );
			face = parseFaceElement( face );
			face = face.stripLeft();

			triangles[i].vertices[1] = vertices[parse!int( face ) - 1];

			// Trash textures and normals for now 
			face = parseFaceElement( face );
			face = parseFaceElement( face );
			face = face.stripLeft();

			triangles[i].vertices[2] = vertices[parse!int( face ) - 1];
		}
	}

	// Trash extra face elements for the time being
	string parseFaceElement( string face )
	{
		if ( face != null && face[0] == '/' )
		{
			parse!char( face );

			// Check if it's only specifying normals
			if ( face[0] != '/' )
			{
				parse!int( face );
			}
		}

		return face;
	}
}

struct triangle
{
	Vec4f[3] vertices;
}
