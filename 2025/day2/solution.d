#!/usr/bin/env -S rdmd -I..
module day2.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;

import common.io;

alias Data = long[][];
Data parse(string fname) {
	Data result = [];
	string[] lines = readLines(fname);
	foreach (range; lines[0].split(',')) {
		result ~= range.split('-').map!(to!long).array;
	}
	return result;
}

auto solve1(Data data) {
	long result = 0;

	foreach (row; data) {
		auto hlen = to!string(row[1]).length / 2;
		
		writeln(row);
		long[] halves = row.map!(to!string).map!(s => s.length == 1 ? "0" : s[0..($-hlen)]).map!(to!long).array; 
		
		writeln(halves);
		for (long i = halves[0]; i <= halves[1]; i++) {
			auto istr = to!string(i);
			auto doubled = to!long(istr ~ istr);
			if (doubled >= row[0] && doubled <= row[1]) {
				writeln(doubled);
				result += doubled;
			}
		}
	}

	writeln(result);
	return result;
}

void main() {
	auto testData = parse("test-input");
	
	assert(solve1(testData) == 1227775554, "Solution incorrect");

	auto data = parse("input");
	auto result = solve1(data);
	// assert(result == 1);
	writeln(result);
}
