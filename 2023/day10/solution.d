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

// enum Dir {
// 	E = 1,
// 	S = 2,
// 	W = 4,
// 	N = 8
// }

auto getAdjacent(const Grid!char grid, const Point pos) {
	byte[char] LOOKUP = [
		//     NWSE
		'|': 0b1010,
		'-': 0b0101,
		'L': 0b1001,
		'J': 0b1100,
		'7': 0b0110,
		'F': 0b0011,
		'.': 0b0000,
		'S': 0b1111,
		'X': 0b0000,
	];

	Point[] deltas = [
		Point(1, 0), Point(0, 1), Point(-1, 0), Point(0, -1)
	];
	int dir = 1;
	int reverse = 4;

	byte b1 = LOOKUP[grid.get(pos)];
		
	Tuple!(int, Point)[] result = [];
	foreach(delta; deltas) {
		Point np = pos + delta;
		if (grid.inRange(np)) {
			// now test if there is a two-way path
			byte b2 = LOOKUP[grid.get(np)];
			if (((b1 & dir) > 0) && ((b2 & reverse) > 0)) {
				result ~= tuple(dir, np);
			}
		}

		dir *= 2;
		reverse *= 2;
		if (reverse == 16) reverse = 1;
	}
	return result;
}

auto bfs(N, E)(N source, N dest, Tuple!(E, N)[] delegate(N) getAdjacent) {
	// Mark all nodes unvisited. Create a set of all the unvisited nodes called the unvisited set.
	// Assign to every node a tentative distance value: set it to zero for our initial node and to infinity for all other nodes. Set the initial node as current.[13]
	
	struct Result {
		int[N] dist;
		N[N] prev;
	}
	Result result;
	result.dist = [ source: 0 ];

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
				result.dist[sibling] = result.dist[current] + 1;
				// writefln("step %s: from %s to %s, visited: %s", result.dist[current] + 1, current, sibling, visited);
				result.prev[sibling] = current;
			}
		}

		if (dest == current) {
			break;
		}
	}

	return result;
}

auto windingRule(Grid!char grid) {
	int sum = 0;
	for (int y = 0; y < grid.size.y; ++y) {
		int rowCount = 0;
		bool inside = false;
		// start at 0
		for (int x = 0; x < grid.size.x; ++x) {
			Point pos = Point(x, y);
			char c = grid.get(pos);
			switch(c) {
				case '.': if (inside) rowCount++; break;
				case '-': case '7': case 'F': /* do nothing */ break;
				case '|': case 'J': case 'L': inside = !inside; break;
				case 'S': inside = !inside; /* do nothing */ break; //TODO -> result is opposite for test. Derive correct result for test solution 
				default: assert(false);
			}
		}
		assert(inside == false); // winding rule must be even
		sum += rowCount;
	}
	return sum;
}
auto solve(string fname) {
	string[] lines = readLines(fname);
	ulong w = lines[0].length;
	ulong h = lines.length;
	auto grid = new Grid!char(w, h);

	Point start;

	foreach(y, line; lines) {
		foreach(x, char c; line) {
			Point pos = Point(to!int(x), to!int(y));
			grid.set(pos, c);
			if (c == 'S') {
				start = pos;
			}
		}
	}

	auto data = bfs(start, Point(-1, -1), (Point node) { return getAdjacent(grid, node); });
	// writeln(to!string(grid));
	// writeln(to!string(start));
	// writeln(to!string(data));

	int maxDist = data.dist.values.maxElement;

	Grid!char badGrid = new Grid!char(grid.size, '.');
	foreach(p; PointRange(grid.size)) {
		if (p in data.prev) {
			badGrid.set(p, grid.get(p));
		}
	}

	Point endNode;
	bool found = false;
	foreach(k, v; data.dist) {
		if (v == maxDist) {
			endNode = k;
			found = true;
			break;
		}
	}
	assert(found);
	
	Grid!char newGrid = new Grid!char(grid.size, '.');
	Point current = data.prev[endNode];
	while (current != start) {
		newGrid.set(current, grid.get(current));
		grid.set(current, 'X');
		current = data.prev[current];
	}

	auto data2 = bfs(start, endNode, (Point node) { return getAdjacent(grid, node); });
	current = data2.prev[endNode];
	while (current != start) {
		newGrid.set(current, grid.get(current));
		grid.set(current, 'Y');
		current = data2.prev[current];
	}
	newGrid.set(start, grid.get(start));
	newGrid.set(endNode, grid.get(endNode));

	writeln(grid.format(""));
	writeln(badGrid.format(""));
	writeln(newGrid.format(""));

	
	return [
		maxDist,
		windingRule(newGrid)
	];
}

void main() {
	// assert(solve("test-input")[0] == 8, "Incorrect solution");
	writeln(solve("input"));
}
