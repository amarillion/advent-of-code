#!/usr/bin/env -S rdmd -I..
module day6.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;

import common.io;
import common.vec;
import common.box;

alias Data = vec2i[];
Data parse(string fname) {
	string[] lines = readLines(fname);
	Data data;
	foreach(line; lines) {
		auto parts = line.split(", ");
		auto x = to!int(parts[0]);
		auto y = to!int(parts[1]);
		data ~= vec2i(x, y);
	}
	return data;
}

auto solve1(Data data) {
	int[vec2i] counts;
	bool[vec2i] isInfinite;
	
	Rect!int bounds = Rect!int(
		// TODO: need constructor with 4 values...
		vec2i(data.map!(p => p.x).minElement - 1, data.map!(p => p.y).minElement - 1),
		vec2i(data.map!(p => p.x).maxElement + 1, data.map!(p => p.y).maxElement + 1)
	);
	foreach(pos; bounds.coordrange) {
		auto minCount = data.map!(p => manhattan(pos-p)).minCount;
		if (minCount[1] == 1) {
			// TODO second iteration... inefficient...
			auto closest = data.filter!(p => manhattan(pos-p) == minCount[0]).front;
			if (closest in counts) { 
				counts[closest]++; 
			} else {
				counts[closest] = 1;
			}
			if(pos.x == 0 || pos.x == bounds.size.x-1 || pos.y == 0 || pos.y == bounds.size.y - 1) {
				isInfinite[closest] = true;
			}
		}
	}

	int maxCount = 0;
	// TODO: declarative way to get max value
	foreach(p, count; counts) {
		if (p !in isInfinite) {
			maxCount = max(maxCount, count);
		}
	}
	return maxCount;
}

void main(string[] args) {
	assert(args.length == 2, "Expecting 1 argument: input file");
	auto data = parse(args[1]);
	writeln(solve1(data));
}
