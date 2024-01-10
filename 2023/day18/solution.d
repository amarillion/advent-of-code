#!/usr/bin/env -S rdmd -I..
module dayX.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;

import common.io;
import common.vec;

alias Data = string[];

Data parse(string fname) {
	string[] lines = readLines(fname);
	return lines;
}

// See: https://www.wikihow.com/Calculate-the-Area-of-a-Polygon
long irregularPolygonArea(Point[] points) {
	
	long sumA = 0;
	long sumB = 0;
	for(int i = 0; i < points.length; ++i) {
		int j = (i + 1) % to!int(points.length);
		sumA += points[i].x * points[j].y;
		sumB += points[i].y * points[j].x;
	}

	return (sumA - sumB) / 2;
}

auto solve1(Data lines) {
	Point[] polygon;
	Point current = Point(0, 0);

	enum Point[char] asDelta = [
		'L': Point(-1, 0),
		'R': Point(1, 0),
		'U': Point(0, -1),
		'D': Point(0, 1)
	];

	long circumference = 0;
	foreach(line; lines) {
		string[] fields = line.split(" ");
		char dir = line[0];
		int num = to!int(fields[1]);

		polygon ~= current;
		circumference += num;
		current += (asDelta[dir] * num);
	}
	assert(current == Point(0, 0)); // must be enclosed.

	writeln(polygon);
	long result = irregularPolygonArea(polygon);
	writeln(result);
	result += circumference / 2;
	writeln(result);
	return result + 1;
}

// 22:24-
void main() {
	auto testData = parse("test-input");
	assert(solve1(testData) == 62, "Solution incorrect");

	auto data = parse("input");
	auto result = solve1(data);
	// assert(result == 1);
	writeln(result);
}
