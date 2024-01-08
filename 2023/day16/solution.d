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
	return fullTrace(grid, Point(0,0), Dir.E);
}

auto solve2(Data grid) {
	long max = 0;
	for (int y = 0; y < grid.size.y; ++y) {
		long val = fullTrace(grid, Point(0, y), Dir.E);
		if (val > max) max = val;
		val = fullTrace(grid, Point(grid.size.x - 1, y), Dir.W);
		if (val > max) max = val;
		writefln("Max: %s", max);
	}
	for (int x = 0; x < grid.size.x; ++x) {
		long val = fullTrace(grid, Point(x, 0), Dir.S);
		if (val > max) max = val;
		val = fullTrace(grid, Point(x, grid.size.y - 1), Dir.N);
		if (val > max) max = val;
		writefln("Max: %s", max);
	}
	return max;
}

struct State {
	Dir dir;
	Point pos;
}

auto fullTrace(Data grid, Point startPos, Dir startDir) {
	bool[Point] visited;
	bool[State] stateVisited;

	Data view = new Data(grid.size.x, grid.size.y, '.');

	void trace(Point pos, Dir dir, int recursionLevel = 0) {
		// writefln("Tracing beam from %s to %s, recursion: %s", pos, SHORT[dir], recursionLevel);
		// writeln(view.format(""), "\n");
		
		while(true) {
			State state = State(dir, pos);
			if (state in stateVisited) return;

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
						// splitterVisited[pos] = true;
						trace(pos, Dir.E, recursionLevel + 1);
						trace(pos, Dir.W, recursionLevel + 1);
						return;
					}
				break;
				case '|': 
					if ((dir == Dir.E) || (dir == Dir.W)) {
						// splitterVisited[pos] = true;
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

			stateVisited[state] = true;
			pos = newPos;
		}
	}

	trace(startPos, startDir);
	writeln(view.format(""), "\n");

	writefln("Trace: %s %s: %s", startPos, SHORT[startDir], visited.length);
	return visited.length;
}

void main() {
	auto testData = parse("test-input");
	assert(solve1(testData) == 46, "Solution incorrect");
	assert(solve2(testData) == 51, "Solution incorrect");

	auto data = parse("input");
	assert(solve1(data) == 7951);
	auto result = solve2(data); 
	assert(result == 8148);
	writeln(result);
}
