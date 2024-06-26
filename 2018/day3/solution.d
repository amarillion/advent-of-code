#!/usr/bin/env -S rdmd -I..
module day3.solution;

import std.stdio;
import std.string;
import std.conv;
import std.regex;
import std.algorithm;

import common.io;
import common.vec;
import common.box;

Rect!int[] parse(string fname) {
	string[] lines = readLines(fname);
	Rect!int[] result = [];
	auto r = regex(r"#(\d+) @ (\d+),(\d+): (\d+)x(\d+)");
	foreach(line; lines) {
		auto m = matchFirst(line, r);
		vec2i base = vec2i(to!int(m[2]), to!int(m[3]));
		vec2i size = vec2i(to!int(m[4]), to!int(m[5]));
		auto rec = Rect!int(base, size);
		result ~= rec;
	}
	return result;
}

Rect!int intersect (Rect!int a, Rect!int b) {
	// if a does not overlap b, throw an assertion error 
	assert(a.overlaps(b));
	// return the intersection
	
	vec2i pos = vec2i(max(a.pos.x, b.pos.x), max(a.pos.y, b.pos.y));
	vec2i size = vec2i(
		min(a.pos.x + a.size.x, b.pos.x + b.size.x) - pos.x, 
		min(a.pos.y + a.size.y, b.pos.y + b.size.y) - pos.y);
	return Rect!int(pos, size);
}

long solve1(Rect!int[] data) {
	int[vec2i] frqMap;
	foreach(rec; data) {
		foreach(point; rec.coordrange) {
			if (point in frqMap)
				frqMap[point]++;
			else
				frqMap[point] = 1;
		}
	}

	long result = 0;
	foreach(point, count; frqMap) {
		if (count > 1) {
			// writefln("Point %s: %s", point, count);
			result++;
		}
	}
	return result;
}

long solve2(Rect!int[] data) {
	for (int i = 0; i < data.length; ++i) {
		// writefln("Rect #%s: %s", i, data[i]);
		bool noOverlap = true;
		for (int j = 0; j < data.length; ++j) {
			if (i == j) continue;
			if (data[i].overlaps(data[j])) {
				// writefln("  overlaps with Rect #%s: %s", j, data[j]);
				noOverlap = false;
				break;
			}
		}
		if (noOverlap) {
			return i + 1;
		}
	}
	return 0;
}

void main(string[] args) {
	assert(args.length == 2, "Expected one argument: input file");
	auto data = parse(args[1]);
	writeln(solve1(data));
	writeln(solve2(data));
}
