#!/usr/bin/env -S rdmd -I..

import common.io;
import common.sparsegrid;
import common.vec;
import std.stdio;
import std.conv;
import std.algorithm;
import std.array;
import std.concurrency;
import std.math;

int optimalLevel(int[] positions, int delegate(int) fuelCost = i => i) {
	int minCost = 0;
	int minLevel = 0;
	bool first = true;
	for (int level = positions.minElement; level <= positions.maxElement; ++level) {
		int cost = 0;
		foreach (pos; positions) {
			cost += fuelCost(abs(level - pos));
		}
		if (first || cost < minCost) {
			minCost = cost;
			minLevel = level;
			first = false;
		}
	}
	return minCost;
}

auto solve (string fname) {
	string line = readLines(fname)[0];
	int[] positions = line.split(",").map!(to!int).array;

	return [
		optimalLevel(positions),
		optimalLevel(positions, i => (i * (i + 1)) / 2),
	];
}

void main(string[] args) {
	assert(args.length == 2, "Expected argument: input file");
	writeln(solve(args[1]));
}