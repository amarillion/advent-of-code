#!/usr/bin/env -S rdmd -O -I..

import common.io;
import common.vec;
import std.stdio;
import std.conv;
import std.algorithm;
import std.array;
import std.concurrency;
import std.math;
import std.range;
import std.typecons;
import common.grid;
import common.coordrange;
import common.dijkstra;

auto getAdjacent(const Grid!int grid, const Point pos) {
	Point[] deltas = [
		Point(0, 1), Point(1, 0), Point(0, -1), Point(-1, 0)
	];
	Point[] result = [];
	foreach(delta; deltas) {
		Point np = pos + delta;
		if (!grid.inRange(np)) continue;
		result ~= np;
	}
	return result;
}

Grid!N expandGrid(N)(Grid!N grid) {
	Grid!N result = new Grid!N(grid.size * 5);
	foreach(p; PointRange(grid.size)) {
		foreach(q; PointRange(Point(5))) {
			
			Point np = p + Point(q.x * grid.size.x, q.y * grid.size.y);
			int val = grid.get(p) + q.x + q.y;
			while (val > 9) { val -= 9; }
			result.set(np, val);
		}
	}
	return result;
}

auto solve (string fname) {
	string[] lines = readLines(fname);
	Point size = Point(to!int(lines[0].length), to!int(lines.length));
	Grid!int grid = new Grid!int(size.x, size.y);
	foreach(pos; PointRange(size)) {
		string digit = to!string(lines[pos.y][pos.x]);
		grid.set(pos, to!int(digit));
	}

	auto result1 = dijkstra!(Point)(
		Point(0),
		n => n == (size - 1),
		n => getAdjacent(grid, n),
		n => grid.get(n)
	);

	Grid!int grid2 = expandGrid(grid);
	// writeln(grid2.format(""));

	auto result2 = dijkstra!(Point)(
		Point(0),
		n => n == (grid2.size - 1),
		n => getAdjacent(grid2, n),
		n => grid2.get(n)
	);

	return [ result1.dist[result1.dest], result2.dist[result2.dest] ];
}

void main() {
	auto result1 = solve("test");
	assert(result1 == [40, 315]); // 714, 2948 is correct
	writeln(result1);

	auto result2 = solve("input");
	assert(result2 == [714, 2948]);
	writeln(result2);
}
