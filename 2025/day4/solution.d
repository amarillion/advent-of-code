#!/usr/bin/env -S rdmd -I..
module day4.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;

import common.io;
import common.grid;
import common.read_grid;
import common.vec;
import common.coordrange;

alias Data = Grid!(2, char);
Data parse(string fname) {
	auto grid = readGrid(new FileReader(fname));
	return grid;
}

static immutable EIGHT_WAYS = [
	Point(0, 1), Point(1, 1), Point(1, 0), Point(1, -1), Point(0, -1), Point(-1, -1), Point(-1, 0), Point(-1, 1)
];

auto countNeighborRolls(Data grid, Point p) {
	int count = 0;
	foreach (delta; EIGHT_WAYS) {
		auto np = p + delta;
		if (grid.inRange(np)) {
			if (grid[np] == '@') {
				count++;
			}
		}
	}
	return count;
}

auto solve1(Data grid) {
	long result = 0;
	foreach(Point p; PointRange(grid.size)) {
		if (grid[p] != '@') {
			continue;
		}
		int count = countNeighborRolls(grid, p);
		if (count < 4) {
			result++;
		}
	}
	return result;
}

auto solve2(Data grid) {
	long result = 0;
	
	while (true) {
		Point[] removals = [];
		foreach(Point p; PointRange(grid.size)) {
			if (grid[p] != '@') {
				continue;
			}
			int count = countNeighborRolls(grid, p);
			if (count < 4) {
				removals ~= p;
			}
		}
		if (removals.length == 0) {
			break;
		}
		foreach(Point p; removals) {
			grid[p] = '.';
		}
		result += removals.length;
	}
	return result;
}

void main(string[] args) {
	assert(args.length == 2, "Expected one argument: input file");
	auto data = parse(args[1]);
	writeln(solve1(data));
	writeln(solve2(data));
}
