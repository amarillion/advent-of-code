#!/usr/bin/env -S rdmd -I..
module day10.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;
import std.regex;

import common.box;
import common.vec;
import common.io;
import common.coordrange;

alias vec2l = vec!(2, long);

struct Particle {
	vec2l pos;
	vec2l delta;
}

alias Data = Particle[];
Data parse(string fname) {
	string[] lines = readLines(fname);
	Particle[] result;

	auto r = regex(r"position=<\s*([-0-9]+),\s*([-0-9]+)> velocity=<\s*([-0-9]+),\s*([-0-9]+)>");
	foreach(line; lines) {
		auto m = matchFirst(line, r);
		Particle p;
		p.pos = vec2l(to!long(m[1]), to!long(m[2]));
		p.delta = vec2l(to!long(m[3]), to!long(m[4]));
		result ~= p;
	}

	return result;
}

auto solve1(Data data) {
	
	long prevSize;
	bool first = true;
	bool[vec2l] lastGrid;
	vec2l prevMin;
	vec2l prevMax; 
	long i = 0;
	while (true) {
		bool[vec2l] grid;

		foreach(ref p; data) {
			p.pos += p.delta;
		}

		vec2l min = data[0].pos;
		vec2l max = data[0].pos;

		foreach(ref p; data) {
			grid[p.pos] = true;
			min = min.eachMin(p.pos);
			max = max.eachMax(p.pos);
		}
		
		long newSize = (max.x - min.x) * (max.y - min.y);
		// if we're increasing in size...
		if (!first && newSize > prevSize) {
			break;
		}

		first = false;
		prevSize = newSize;
		lastGrid = grid.dup;
		i++;
		prevMin = min;
		prevMax = max;
		// writefln("%02d: %s", i, newSize);
	}

	for(long y = prevMin.y; y <= prevMax.y; ++y) {
		for (long x = prevMin.x; x <= prevMax.x; ++x) {
			vec2l p = vec2l(x, y);
			write(p in lastGrid ? '#' : '.');
		}
		writeln();
	}

	return i;
}

void main(string[] args) {
	assert(args.length == 2, "Expecting 1 argument: input file");
	auto data = parse(args[1]);
	writeln(solve1(data));
}
