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

// enum Dir {
// 	E = 1,
// 	S = 2,
// 	W = 4,
// 	N = 8
// }

auto getAdjacent(const Grid!byte grid, const Point pos) {
	Point[] deltas = [
		Point(1, 0), Point(0, 1), Point(-1, 0), Point(0, -1)
	];
	int dir = 1;
	int reverse = 4;

	byte b1 = grid.get(pos);
		
	Tuple!(int, Point)[] result = [];
	foreach(delta; deltas) {
		Point np = pos + delta;
		if (!grid.inRange(np)) continue;
		
		// now test if there is a two-way path
		byte b2 = grid.get(np);
		writefln("Checking neighbor of %s at %s b1: %04b test %04b b2 %04b test %04b", pos, np, b1, dir, b2, reverse);

		if (((b1 & dir) > 0) && ((b2 & reverse) > 0)) {
			result ~= tuple(dir, np);
		}

		dir *= 2;
		reverse *= 2;
		if (reverse == 16) reverse = 1;
	}
	writefln("%s character %s has siblings %s", pos, b1, result);
	return result;
}

auto bfs(N, E)(N source, N dest, Tuple!(E, N)[] delegate(N) getAdjacent) {
	// Mark all nodes unvisited. Create a set of all the unvisited nodes called the unvisited set.
	// Assign to every node a tentative distance value: set it to zero for our initial node and to infinity for all other nodes. Set the initial node as current.[13]
	
	int[N] result = [ source: 0 ];
	bool[N] visited;
	
	const(N)[] open = [ source ];
	visited[source] = true;

	while (open.length > 0) {
		
		N current = open[0];
		open.popFront();

		// check adjacents
		foreach(pair; getAdjacent(current)) {
			N sibling = pair[1];
			if (!(sibling in visited)) {
				open ~= sibling;
				visited[sibling] = true;
				// set or update distance
				result[sibling] = result[current] + 1;
			}
		}

		if (dest == current) {
			break;	
		}
	}

	return result;
}

auto solve(string fname) {
	string[] lines = readLines(fname);
	ulong w = lines[0].length;
	ulong h = lines.length;
	auto grid = new Grid!byte(w, h);

	byte[char] LOOKUP = [
		//     NWSE
		'|': 0b1010,
		'-': 0b0101,
		'L': 0b1001,
		'J': 0b1100,
		'7': 0b0110,
		'F': 0b0011,
		'.': 0b0000,
		'S': 0b1111
	];

	Point start;

	foreach(y, line; lines) {
		foreach(x, char c; line) {
			Point pos = Point(to!int(x), to!int(y));
			grid.set(pos, LOOKUP[c]);
			if (c == 'S') {
				start = pos;
			}
		}
	}

	auto data = bfs(start, Point(-1, -1), (Point node) { return getAdjacent(grid, node); });
	
	// writeln(to!string(grid));
	writeln(to!string(start));
	writeln(to!string(data));

	int result = data.values.maxElement;

	return [
		result
	];
}

void main() {
	assert(solve("test-input") == [ 8 ], "Incorrect solution");
	writeln(solve("input"));
}
