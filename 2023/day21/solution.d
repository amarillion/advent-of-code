#!/usr/bin/env -S rdmd -I..
module day21.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;

import common.io;
import common.grid;
import common.bfs;
import common.vec;
import common.coordrange;
import common.cardinal;

alias MyGrid = Grid!(2, char);
MyGrid parse(string fname) {
	return readGrid(new FileReader(fname));
}

Point[] getAdjacent(const MyGrid grid, Point pos) {
	Point[] result;
	foreach(Point delta; DELTA.values) {
		Point np = pos + delta;
		if (grid.inRange(np)) {
			if (grid[np] != '#') {
				result ~= np;
			}
		}
	}
	return result;
}

auto solve1(MyGrid grid, int steps) {
	Point start;
	foreach(Point p; PointRange(grid.size)) {
		if (grid[p] == 'S') {
			start = p;
		}
	}
	auto result = bfs!Point(
		start,
		(Point p) => false,
		(Point p) => getAdjacent(grid, p)
	);
	writeln(result.dist);
	return result.dist.values.filter!(i => i <= steps && i % 2 == 0).count();
}

void main() {
	auto testData = parse("test-input");
	assert(solve1(testData, 6) == 16, "Solution incorrect");

	auto data = parse("input");
	auto result = solve1(data, 64);
	assert(result == 3764);
	writeln(result);
}
