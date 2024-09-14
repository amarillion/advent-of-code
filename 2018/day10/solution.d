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
import common.sparsegrid;

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
	SparseInfiniteGrid!(vec2l, bool) lastGrid;
	long i = 0;
	while (true) {
		auto nextGrid = new SparseInfiniteGrid!(vec2l, bool)();

		foreach(ref p; data) {
			p.pos += p.delta;
			nextGrid.set(p.pos, true);
		}
		
		long newSize = (nextGrid.max.x - nextGrid.min.x) * (nextGrid.max.y - nextGrid.min.y);
		// if we're increasing in size...
		if (!first && newSize > prevSize) {
			break;
		}

		first = false;
		prevSize = newSize;
		lastGrid = nextGrid;
		i++;
		// writefln("%02d: %s", i, newSize);
	}

	writeln(lastGrid.format!((bool b) { return b ? "#" : "."; })(""));
	return i;
}

void main(string[] args) {
	assert(args.length == 2, "Expecting 1 argument: input file");
	auto data = parse(args[1]);
	writeln(solve1(data));
}
