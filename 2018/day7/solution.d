#!/usr/bin/env -S rdmd -I..
module day7.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;
import std.regex;

import common.io;

alias Data = dchar[][dchar];
Data parse(string fname) {
	string[] lines = readLines(fname);
	Data data;
	foreach(line; lines) {
		auto result = line.matchFirst(r"Step (\w) must be finished before step (\w) can begin.");
		dchar before = result[1][0];
		dchar after = result[2][0];
		if (after !in data) {
			data[after] = [ before ];
		}
		else {
			data[after] ~= before;
		}
		// make sure all keys are in.
		if (before !in data) {
			data[before] = [];
		}
	}
	return data;
}

auto solve1(Data data) {
	dchar[] result;

	auto remain = data.dup;
	while (!remain.empty) {
		dchar[] available;
		foreach(dchar k, v; remain) {
			if (v.empty) {
				available ~= k;
			}
		}
		sort!"a < b"(available);
		dchar found = available[0];
		
		// remove found from both key and values.
		remain.remove(found);
		foreach(k, ref dchar[] v; remain) {
			v = to!(dchar[])(v.filter!(c => c != found).array); // Why is cast to dchar[] necessary? D trying to do funky business with utf8?
		}

		result ~= found;
	}
	return result;
}

void main(string[] args) {
	assert(args.length == 2, "Expecting 1 argument: input file");
	auto data = parse(args[1]);
	writeln(solve1(data));
}