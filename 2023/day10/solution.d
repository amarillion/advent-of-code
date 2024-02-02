#!/usr/bin/env -S rdmd -I..
module day10.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.typecons;
import std.algorithm;

import common.grid;
import common.io;
import common.vec;
import common.coordrange;
import common.bfs;

enum Dir {
	E = 1,
	S = 2,
	W = 4,
	N = 8
}

enum Dir[Dir] REVERSE = [
	Dir.N: Dir.S,
	Dir.E: Dir.W,
	Dir.S: Dir.N,
	Dir.W: Dir.E
];

enum byte[char] LOOKUP = [
	//     NWSE
	'|': 0b1010,
	'-': 0b0101,
	'L': 0b1001,
	'J': 0b1100,
	'7': 0b0110,
	'F': 0b0011,
	'.': 0b0000,
	'S': 0b1111,
];

enum Point[Dir] DELTA = [
	Dir.E: Point(1, 0), 
	Dir.S: Point(0, 1), 
	Dir.W: Point(-1, 0), 
	Dir.N: Point(0, -1)
];

alias MyGrid = Grid!(2, char);

bool isLink(const MyGrid grid, const Point pos, Dir dir) {
	Point np = pos + DELTA[dir];
	if (!grid.inRange(np)) return false;
	return 
		(LOOKUP[grid[pos]] & dir) &&
		(LOOKUP[grid[np]] & REVERSE[dir]);
}

auto getAdjacent(const MyGrid grid, const Point pos) {
	Tuple!(Dir, Point)[] result = [];
	foreach(dir; [Dir.E, Dir.S, Dir.W, Dir.N]) {
		if (isLink(grid, pos, dir)) {
			Point np = pos + DELTA[dir];
			result ~= tuple(dir, np);
		}
	}
	return result;
}

auto windingRule(const MyGrid grid) {
	int sum = 0;
	for (int y = 0; y < grid.size.y; ++y) {
		int rowCount = 0;
		bool inside = false;
		// start at 0
		for (int x = 0; x < grid.size.x; ++x) {
			
			Point pos = Point(x, y);
			char c = grid[pos];
			if (c == '.') {
				if (inside) rowCount++;
			}
			// our winding test goes through the top side of the row.
			// apply winding rule if there is a connection to above.
			else if (isLink(grid, pos, Dir.N)) {
				inside = !inside;
			}
		}
		assert(inside == false); // winding rule must be even
		sum += rowCount;
	}
	return sum;
}
auto solve(string fname) {
	
	auto grid = readGrid(new FileReader(fname));

	Point start;
	foreach(pos; PointRange(grid.size)) {
		if (grid[pos] == 'S') start = pos;
	}

	auto data = bfs(start, (Point node) => false, (Point node) => getAdjacent(grid, node) );

	int maxDist = data.dist.values.maxElement;

	// clear all junk that is not part of the loop
	foreach(p; PointRange(grid.size)) {
		if (!(p in data.dist)) {
			grid[p] = '.';
		}
	}

	// writeln(grid.format(""));
	
	return [
		maxDist,
		windingRule(grid)
	];
}

void main(string[] args) {
	assert(args.length == 2, "Expected one argument: input file");
	auto result = solve(args[1]);
	writeln(result);
}
