#!/usr/bin/env -S rdmd -I..
module day23.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;
import std.typecons;

import common.io;
import common.vec;
import common.grid;
import common.cardinal;

alias MyGrid = Grid!(2, char);

MyGrid parse(string fname) {
	return readGrid(new FileReader(fname));
}

Tuple!(Dir, Point)[] getAdjacent(const MyGrid grid, Point pos) {
	Tuple!(Dir, Point)[] result;
	foreach(dir; [Dir.E, Dir.S, Dir.W, Dir.N]) {
		Point np = pos + DELTA[dir];
		if (grid.inRange(np)) {
			if (grid[np] == '.' || grid[np] == SHORT[dir]) {
				result ~= tuple(dir, np);
			}
		}
	}
	return result;
}

long longestPath(const MyGrid grid) {
	Tuple!(Dir, Point)[] path;
	
	Point start = Point(1, 0);
	bool[Point] visited;
	long len = 0;
	long maxLen = 0;
	Point current = start;
	Point end = grid.size - Point(2, 1);
	int prevChoice = 0;
	long[] lengths = [];

	while(true) {
		writefln("Currently at #%s: %s", len, current);

		// forward
		auto options = getAdjacent(grid, current);
		visited[current] = true;
		bool found = false;
		foreach(option; options) {
			if (option[0] <= prevChoice) continue;
			
			// pick first viable option...
			if (option[1] !in visited) {
				path ~= option;
				found = true;
				break;
			}
		}

		if (found) {
			writefln("Moving forward %s %s", path[$-1][0], path[$-1][1]);
			len++;
			current = path[$-1][1];
			prevChoice = 0;

			if (current == end) {
				// save result
				lengths ~= len;
				writefln("Reached end, added another path: %s", lengths);
				if (len > maxLen) { maxLen = len; }
			}
		}
		
		if (!found || current == end) {
			// backtrack one step.
			visited.remove(path[$-1][1]);
			prevChoice = path[$-1][0];
			path.popBack();
			len--;

			if (path.empty) {
				writeln("Bactracked all the way to start");
				// backtracked all the way to start...
				break;
			}

			current = path[$-1][1];
			writefln("Backtracking to %s prevChoice %s", current, prevChoice);
		}

		// stdin.readln();
	}

	return maxLen;
}

auto solve1(MyGrid data) {
	long result = longestPath(data);
	writeln(result);
	return result;
}

void main() {
	auto testData = parse("test-input");
	assert(solve1(testData) == 94, "Solution incorrect");

	auto data = parse("input");
	auto result = solve1(data);
	// assert(result == 1);
	writeln(result);
}
