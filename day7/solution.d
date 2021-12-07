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

int optimalPos(int[] positions, int delegate(int) fuelCost) {
	writefln ("Total: %s count %s ", positions.sum, positions.length);
	writeln ("Avg: ", cast(double)positions.sum / cast(double)positions.length);
	writefln ("Min: %s, Max: %s ", positions.minElement, positions.maxElement);

	int sum = positions.sum;
	int minCost = 0;
	int minLevel = 0;
	bool first = true;
	for (int level = positions.minElement; level <= positions.maxElement; ++level) {
		int cost = 0;
		foreach (pos; positions) {
			cost += fuelCost(abs(level - pos));
			// writefln("Move from %s to %s: %s fuel", pos, level, abs(level - pos));
		}
		if (first || cost < minCost) {
			minCost = cost;
			minLevel = level;
			first = false;
		}
		writefln("%s %s", level, cost);
	}
	writefln("Best: %s %s", minLevel, minCost);
	return minCost;
}

auto solve (string fname) {
	string line = readLines(fname)[0];
	int[] positions = line.split(",").map!(to!int).array;

	int[] fuelCosts;
	int prev = 0;
	for (int i = 0; i <= positions.maxElement; ++i) {
		prev += i; 
		fuelCosts ~= prev;
	}
	writeln(fuelCosts);

	return [
		optimalPos(positions, i => i),
		optimalPos(positions, i => fuelCosts[i]),
	];
}

void main() {
	assert (solve("test") == [ 37, 168 ]);
	writeln (solve("input"));
}