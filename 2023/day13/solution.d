#!/usr/bin/env -S rdmd -I..
module day13.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;

import common.io;
import common.grid;

alias Data = Grid!(2, char)[];

Data parse(string fname) {
	auto reader = new FileReader(fname);
	Data result;
	while(!reader.eof) {
		result ~= readGrid(reader);
	}
	return result;
}

long countRangeDifferences(Range)(Range a, Range b) {
	long result = 0;
	while (!(a.empty || b.empty)) {
		if (a.front != b.front) result++;
		a.popFront();
		b.popFront();
	}
	return result;
}

bool expectedSymmetricDifferences(Grid!(2, char) grid, int center, bool isVertical, long expected) {
	int size = isVertical ? grid.width : grid.height;
	long result = 0;
	for (int x = 0; x < size; ++x) {
		int x1 = center - x;
		int x2 = center + x + 1;
		if (x1 < 0 || x2 >= size) return result == expected;
		if (isVertical) {
			result += countRangeDifferences(grid.col[x1], grid.col[x2]);
		}
		else {
			result += countRangeDifferences(grid.row[x1], grid.row[x2]);
		}
		if (result > expected) return false;
	}
	return result == expected;
}

auto solve(Data data, long expected) {
	long result = 0;
	foreach(grid; data) {
		// check for horizontal symmetry. Count no. of differences for a given axis of symmetry.
		int vsymmetry = -1;
		for (int x = 0; x < grid.size.x - 1; ++x) {
			bool valid = expectedSymmetricDifferences(grid, x, true, expected);
			// writefln(" Vertical: %s %s", x, delta);
			if (valid) {
				vsymmetry = x + 1;
				break;
			}
		}

		int hsymmetry = -1;
		for (int y = 0; y < grid.size.y - 1; ++y) {
			bool valid = expectedSymmetricDifferences(grid, y, false, expected);
			// writefln("Horizontal: %s %s", y, delta);
			if (valid) {
				hsymmetry = y + 1;
				break;
			}
		}
		// writeln(grid.size);
		// writeln(grid.format(""));
		if (hsymmetry > 0) result += hsymmetry * 100;
		if (vsymmetry > 0) result += vsymmetry;
		// writefln("HSymmetry: %s; VSymmetry: %s; sum: %s", hsymmetry, vsymmetry, result);
	}
	return result;
}

void main(string[] args) {
	assert(args.length == 2, "Expected one argument: input file");

	auto data = parse(args[1]);
	auto result = [ solve(data, 0), solve(data, 1) ];
	writeln(result);
}
