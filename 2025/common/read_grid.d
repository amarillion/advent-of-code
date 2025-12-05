module common.read_grid;

import std.file;
import std.string;
import std.stdio;
import std.conv;
import std.range;

import common.grid;
import common.vec;
import common.io;

/** 
 * Reads a character grid from InputReader.
 * 
 * Expect input to consist of h lines of w characters each.
 * Stops reading at empty lines
 *
 * Optional converter can be used to process each char and create a differently typed grid.
 */
auto readGrid(alias Converter = (char c) => c)(InputReader reader) {
	string[] lines = [];
	{
		string line;
		while((line = reader.readLine()) != null) {
			if (line == "") break; 
			lines ~= line;
		}
	}

	ulong w = lines[0].length;
	ulong h = lines.length;

	// Using this instead of: ReturnType!Converter, because that fails with: 
	// readGrid!(to!byte) -> Error: template instance `common.io.readGrid!(to)` error instantiating
	alias ConverterType = typeof({ return Converter('c'); }() );
	auto grid = new Grid!(2, ConverterType)(to!int(w), to!int(h));
	
	foreach(y, line; lines) {
		foreach(x, char c; line) {
			Point pos = Point(to!int(x), to!int(y));
			grid[pos] = Converter(c);
		}
	}

	return grid;
}

unittest {
	// no line ending...
	auto grid = readGrid(new StringReader("ab\ncd"));
	assert(to!string(grid) == "a, b\nc, d");
}

unittest {
	auto grid = readGrid(new StringReader("abcd\nefgh\n\n"));
	assert(to!string(grid) == "a, b, c, d\ne, f, g, h");
}

unittest {
	// using converter
	auto grid = readGrid!(to!byte)(new StringReader("1234\n5678\n\n"));
	assert(typeof(grid).stringof == "Grid!(2, byte)"); // correct type deduced...
	assert(to!string(grid) == "49, 50, 51, 52\n53, 54, 55, 56");
}