#!/usr/bin/env -S rdmd -I..

import common.io;
import common.vec;
import std.stdio;
import std.conv;
import std.algorithm;
import std.array;
import std.concurrency;
import std.math;
import std.range;
import std.uni;
import common.util;
import common.coordrange;
import common.box;

struct Result {
	bool hit = false;
	int maxHeight = int.min;
	int maxRight = int.min;
}

Result simulate(Point initialV, Rect!int rect) {
	Result result;
	Point v = initialV;
	Point pos = Point(0, 0);
	while(pos.y >= rect.pos.y) {
		pos += v;
		v.x -= sgn(v.x); // towards 0 in steps of 1
		v.y--;
		result.hit |= (rect.contains(pos));
		result.maxHeight = max(pos.y, result.maxHeight);
		result.maxRight = max(pos.x, result.maxRight);
	}
	return result;
}

auto solve (string fname) {
	string line = readLines(fname)[0]["target area: ".length..$];
	int[][] coords = line.split(", ").map!(s => s["x=".length..$].split("..").map!(to!int).array).array;
	sort(coords[0]);
	sort(coords[1]);
	Point bottomLeft = Point(coords[0][0], coords[1][0]);
	Point topRight = Point(coords[0][1], coords[1][1]);
	auto rect = Rect!int(bottomLeft, topRight - bottomLeft + 1);
	
	int maxSuccess = int.min;
	int successes = 0;

	// scanning range determined through trial and error.
	// TODO: could be improved by automatically determining scanning range
	foreach(initialV; PointRange(Point(0, -400), Point(400, 400))) {
		Result result = simulate(initialV, rect);
		if (result.hit) {
			if (result.maxHeight > maxSuccess) {
				maxSuccess = result.maxHeight;
			}
			successes++;
		}
	}

	return [ maxSuccess, successes ];
}

void main() {
	assert (solve("test") == [ 45, 112 ]);
	auto result = solve("input");
	assert (result == [4005, 2953]);
	writeln (result);
}
