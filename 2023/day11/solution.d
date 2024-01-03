#!/usr/bin/env -S rdmd -I..
module day11.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;

import common.io;
import common.vec;
import common.pairwise;

auto solve(string fname, long part2growFactor) {
	string[] lines = readLines(fname);
	ulong w = lines[0].length;
	ulong h = lines.length;

	Point[] galaxies;
	bool[] emptyRows = repeat(true, w).array;
	bool[] emptyColumns = repeat(true, h).array;

	foreach(y, line; lines) {
		foreach(x, char c; line) {
			if (c == '#') {
				galaxies ~= Point(to!int(x), to!int(y));
				emptyRows[y] = false;
				emptyColumns[x] = false;
			}
		}
	}

	long distance(Point g1, Point g2, long growFactor = 2) {
		long result = 0;
		for (int x = min(g1.x, g2.x); x < max(g1.x, g2.x); ++x) {
			if (emptyColumns[x]) result += growFactor; else result += 1;
		}
		for (int y = min(g1.y, g2.y); y < max(g1.y, g2.y); ++y) {
			if (emptyRows[y]) result += growFactor; else result += 1;
		}
		return result;
	}

	return [
		galaxies
			.pairwise
			.map!((pair) => distance(pair[0], pair[1]))
			.sum,
		galaxies
			.pairwise
			.map!((pair) => distance(pair[0], pair[1], part2growFactor))
			.sum
	];
}

void main() {
	assert(solve("test-input", 100) == [ 374, 8410 ], "Incorrect solution");
	auto result = solve("input", 1_000_000);
	assert(result == [9_639_160, 752_936_133_304]);
	writeln(result);
}
