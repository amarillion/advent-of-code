#!/usr/bin/env -S rdmd -I..
module day18.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;

import common.io;
import common.vec;

alias Data = string[];

alias vec2l = vec!(2, long);

Data parse(string fname) {
	string[] lines = readLines(fname);
	return lines;
}

// See: https://www.wikihow.com/Calculate-the-Area-of-a-Polygon
long irregularPolygonArea(vec2l[] points) {
	
	long sumA = 0;
	long sumB = 0;
	for(int i = 0; i < points.length; ++i) {
		int j = (i + 1) % to!int(points.length);
		sumA += points[i].x * points[j].y;
		sumB += points[i].y * points[j].x;
	}

	return (sumA - sumB) / 2;
}

struct Instruction {
	long num;
	char dir;
}

auto parse1(Data lines) {
	Instruction[] result;
	foreach(line; lines) {
		string[] fields = line.split(" ");
		char dir = line[0];
		int num = to!int(fields[1]);
		result ~= Instruction(num, dir);
	}
	return result;
}

auto parse2(Data lines) {
	Instruction[] result;

	enum char[char] asDir = [
		'0': 'R',
		'1': 'D',
		'2': 'L',
		'3': 'U'
	];

	foreach(line; lines) {
		string[] fields = line.split(" ");
		string color = fields[2];
		
		int num = to!int(to!ulong(color[2..$-2], 16));
		char dir = asDir[color[$-2]];
		result ~= Instruction(num, dir);
	}
	writeln(result);
	return result;
}

auto solve(Instruction[] instructions) {
	vec2l[] polygon;
	vec2l current = vec2l(0, 0);

	enum vec2l[char] asDelta = [
		'L': vec2l(-1, 0),
		'R': vec2l(1, 0),
		'U': vec2l(0, -1),
		'D': vec2l(0, 1)
	];

	long circumference = 0;
	foreach(insr; instructions) {
		polygon ~= current;
		circumference += insr.num;
		current += (asDelta[insr.dir] * insr.num);
	}
	assert(current == vec2l(0, 0)); // must be enclosed.

	writeln(polygon);
	long result = irregularPolygonArea(polygon);
	writeln(result);
	result += circumference / 2;
	writeln(result);
	return result + 1;
}

void main() {
	auto testData = parse("test-input");
	assert(solve(parse1(testData)) == 62, "Solution incorrect");
	assert(solve(parse2(testData)) == 952_408_144_115, "Solution incorrect");

	auto data = parse("input");
	auto result = solve(parse1(data));
	assert(result == 31_171);
	writeln(result);
	
	result = solve(parse2(data));
	assert(result == 131_431_655_002_266);
	writeln(result);
}
