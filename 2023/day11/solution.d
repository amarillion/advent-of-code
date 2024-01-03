#!/usr/bin/env -S rdmd -I..
module day11.solution;

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


auto solve(string fname, long part2Factor) {
	string[] lines = readLines(fname);
	ulong w = lines[0].length;
	ulong h = lines.length;

	Point[] galaxies;
	bool[] emptyRows = repeat(true, w).array;
	bool[] emptyColumns = repeat(true, h).array;

	// copy file into grid
	foreach(y, line; lines) {
		foreach(x, char c; line) {
			Point pos = Point(to!int(x), to!int(y));
			if (c == '#') {
				galaxies ~= pos;
				emptyRows[y] = false;
				emptyColumns[x] = false;
			}
		}
	}

	writeln(emptyRows);
	writeln(emptyColumns);
	writeln(galaxies);

	long distance(Point g1, Point g2, long factor = 2) {
		long result = 0;
		for (int x = min(g1.x, g2.x); x < max(g1.x, g2.x); ++x) {
			if (emptyColumns[x]) result += factor; else result += 1;
		}
		for (int y = min(g1.y, g2.y); y < max(g1.y, g2.y); ++y) {
			if (emptyRows[y]) result += factor; else result += 1;
		}
		return result;
	}

	long result1 = 0;
	long result2 = 0;
	for(int i = 0; i < galaxies.length; ++i) {
		for (int j = 0; j < i; ++j) {
			long d1 = distance(galaxies[i], galaxies[j]);
			long d2 = distance(galaxies[i], galaxies[j], part2Factor);
			writefln("Galaxy #%s: %s - #%s: %s distance: %s %s", i, galaxies[i], j, galaxies[j], d1, d2);
			result1 += d1;
			result2 += d2;
		}
	}

	return [
		result1, result2
	];
}

void main() {
	assert(solve("test-input", 100) == [ 374, 8410 ], "Incorrect solution");
	auto result = solve("input", 1_000_000);
	// assert(result == [9639160]);
	writeln(result);
}
