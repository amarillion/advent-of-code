#!/usr/bin/env -S rdmd -I..
module day1.solution;

import std.stdio;
import std.string;
import std.conv;
import std.algorithm;
import std.array;

import common.io;

long solve2(long[] vals) {
	bool[long] reached;	
	bool found = false;
	long frq = 0;
	while(!found) {
		foreach(val; vals) {
			frq += val;
			if (frq in reached) {
				found = true;
				break;
			}
			reached[frq] = true;
		}
	}

	return frq;
}

void main(string[] args) {
	assert(args.length == 2, "Expected one argument: <input file>");
	long[] values = readLines(args[1]).map!(to!long).array;
	writeln(sum(values));
	writeln(solve2(values));
}
