#!/usr/bin/env -S rdmd -I..

import std.array;
import std.algorithm;
import std.stdio;
import std.conv;
import common.io;

int calc1(string str) {
	int[] dim = str.split("x").map!(to!int).array;
	int[] areas = [ dim[0] * dim[1], dim[0] * dim[2], dim[1] * dim[2] ];
	sort(areas);
	return 3 * areas[0] + 2 * areas[1] + 2 * areas[2];
}

int calc2(string str) {
	int[] dim = str.split("x").map!(to!int).array;
	sort(dim);
	return dim[0] * 2 + dim[1] * 2 + dim[0] * dim[1] * dim[2];
}

void main() {
	assert(calc1("2x3x4") == 58);
	assert(calc1("1x1x10") == 43);

	assert(calc2("2x3x4") == 34);
	assert(calc2("1x1x10") == 14);

	string[] lines = readLines("input");
	writeln([
		lines.map!calc1.sum,
		lines.map!calc2.sum
	]);
}
