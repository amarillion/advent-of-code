#!/usr/bin/env -S rdmd -I..
module day16.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;

import common.io;
import common.grid;
import common.cardinal;
import common.vec;

alias Data = Grid!(2, char);
auto parse(string fname) {
	return readGrid(new FileReader(fname));
}

auto solve1(Data grid) {
	bool[Point] visited;
	Data view = new Data(grid.size.x, grid.size.y, '.');

	void trace(Point pos, Dir dir, int recursionLevel = 0) {
		// writefln("Tracing beam from %s to %s, recursion: %s", pos, SHORT[dir], recursionLevel);
		// writeln(view.format(""), "\n");
		if (recursionLevel > 20) { return; }

		while(true) {
			// writefln("%s %s", pos, grid[pos]);
			visited[pos] = true;
			view[pos] = '#';

			switch(grid[pos]) {
				case '.': break;
				case '/': { 
					enum Dir[Dir] TURN = [
						Dir.N: Dir.E,
						Dir.E: Dir.N,
						Dir.W: Dir.S,
						Dir.S: Dir.W
					];
					dir = TURN[dir];
				} break;
				case '\\': {
					enum Dir[Dir] TURN = [
						Dir.N: Dir.W,
						Dir.W: Dir.N,
						Dir.E: Dir.S,
						Dir.S: Dir.E
					];
					dir = TURN[dir];
				} break;
				case '-':
					if ((dir == Dir.N) || (dir == Dir.S)) {
						trace(pos, Dir.E, recursionLevel + 1);
						trace(pos, Dir.W, recursionLevel + 1);
						return;
					}
				break;
				case '|': 
					if ((dir == Dir.E) || (dir == Dir.W)) {
						trace(pos, Dir.S, recursionLevel + 1);
						trace(pos, Dir.N, recursionLevel + 1);
						return;
					}
				break;
				default: assert(false);
			}

			Point delta = DELTA[dir];
			Point newPos = pos + delta;			
			if (!grid.inRange(newPos)) return;

			pos = newPos;
		}
	}

	trace(Point(0,0), Dir.E);
	writeln(view.format(""), "\n");

	return visited.length;
}

void main() {
	auto testData = parse("test-input");
	assert(solve1(testData) == 46, "Solution incorrect");

	auto data = parse("input");
	auto result = solve1(data);
	assert(result == 7951);
	writeln(result);
}
