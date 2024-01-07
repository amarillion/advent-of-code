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

long countSymmetricDifferences(Grid!(2, char) grid, int center, bool isVertical) {
	int size = isVertical ? grid.width : grid.height;
	long result = 0;
	for (int x = 0; x < size; ++x) {
		int x1 = center - x;
		int x2 = center + x + 1;
		if (x1 < 0 || x2 >= size) return result;
		if (isVertical) {
			result += countRangeDifferences(grid.col[x1], grid.col[x2]);
		}
		else {
			result += countRangeDifferences(grid.row[x1], grid.row[x2]);
		}
	}
	return result;
}

auto solve(Data data, long expected) {
	long result = 0;
	foreach(grid; data) {
		// check for horizontal symmetry. Find consecutive matches
		int vsymmetry = -1;
		for (int x = 0; x < grid.size.x - 1; ++x) {
			long delta = countSymmetricDifferences(grid, x, true);
			writefln(" Vertical: %s %s", x, delta);
			if (delta == expected) {
				vsymmetry = x + 1;
				break;
			}
		}

		int hsymmetry = -1;
		for (int y = 0; y < grid.size.y - 1; ++y) {
			long delta = countSymmetricDifferences(grid, y, false);
			writefln("Horizontal: %s %s", y, delta);
			if (delta == expected) {
				hsymmetry = y + 1;
				break;
			}
		}

		writeln(grid.size);
		writeln(grid.format(""));

		if (hsymmetry > 0) result += hsymmetry * 100;
		if (vsymmetry > 0) result += vsymmetry;
		writefln("HSymmetry: %s; VSymmetry: %s; sum: %s", hsymmetry, vsymmetry, result);
	}
	return result;
}

void main() {
	auto testData = parse("test-input");
	assert(solve(testData, 0) == 405, "Solution incorrect");
	assert(solve(testData, 1) == 400, "Solution incorrect");

	auto data = parse("input");
	auto result = solve(data, 0);
	assert(result == 31_739);
	result = solve(data, 1);
	// assert(result == 31_739);
	writeln(result);
}
