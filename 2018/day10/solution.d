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
	vec2l min;
	vec2l max; 
	long i = 0;
	while (true) {
		bool[vec2l] grid;
		i++;
		min = vec2l(0);
		max = vec2l(0);
		foreach(ref p; data) {
			p.pos += p.delta;
		}

		foreach(ref p; data) {
			grid[p.pos] = true;
			min = min.eachMin(p.pos);
			max = max.eachMax(p.pos);
		}
		
		writeln(max, " ", min);
		long newSize = (max.x - min.x) * (max.y - min.y);
		// if we're increasing in size...
		if (!first && newSize > prevSize) {
			break;
		}

		writefln("%02d: %s", i, newSize);
		first = false;
		prevSize = newSize;
		lastGrid = grid.dup;
	}

	for(long y = min.y - 1; y < max.y + 2; ++y) {
		for (long x = min.x - 1; x < max.x + 2; ++x) {
			vec2l p = vec2l(x, y);
			write(p in lastGrid ? '#' : '.');
		}
		writeln();
	}

	long result = 0;
	return result;
}

void main(string[] args) {
	assert(args.length == 2, "Expecting 1 argument: input file");
	auto data = parse(args[1]);
	writeln(solve1(data));
}
