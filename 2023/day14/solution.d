#!/usr/bin/env -S rdmd -I..
module day14.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;

import common.io;
import common.grid;
import common.vec;
import common.coordrange;

alias Data = Grid!(2, char);
Data parse(string fname) {
	return readGrid(new FileReader(fname));
}

void moveUp(Data grid, Point pos) {
	Point current = pos;
	while(true) {
		Point np = current + Point(0, -1);
		if (!grid.inRange(np)) break;
		if (grid[np] != '.') break;
		grid[current] = '.';
		grid[np] = 'O';
		current = np;
	}
}

auto solve1(Data grid) {
	// move all 'O's up
	writeln(grid.format());

	foreach(Point p; PointRange(grid.size)) {
		if(grid[p] == 'O') {
			moveUp(grid, p);
		}
	}

	writeln(grid.format());
	
	// count positions of O's	
	long result = 0;
	foreach(Point p; PointRange(grid.size)) {
		if(grid[p] == 'O') {
			long val = grid.size.y - p.y;
			writefln("Found O on %s", val);
			result += val;
		}
	}

	return result;
}

void main() {
	auto testData = parse("test-input");
	assert(solve1(testData) == 136, "Solution incorrect");

	auto data = parse("input");
	auto result = solve1(data);
	assert(result == 106_990);
	writeln(result);
}
