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

auto getRepeats(long[] range, int numParts = 2) {
	bool[long] result = null;

	auto len = to!string(range[1]).length;
	// assert(len % numParts == 0); // evenly dividable.
	auto hlen = len / numParts;
	
	long[] prefix = range.map!(to!string).map!(s => s.rightJustify(len, '0')[0..hlen]).map!(to!long).array; 
	// writefln("Testing range %s split in %s with prefixes %s", range,  numParts, prefix);

	for (long i = prefix[0]; i <= prefix[1]; i++) {
		auto istr = to!string(i);
		auto repeated = to!long(istr.repeat(numParts).join(""));
		if (repeated >= range[0] && repeated <= range[1]) {
			// writeln(repeated);
			result[repeated] = true;
		}
	}

	return result;
}

auto solve1(Data data) {
	long result = 0;

	foreach (row; data) {
		auto len1 = to!string(row[0]).length;
		auto len2 = to!string(row[1]).length;
		
		if (len1 != len2) {
			// make it two ranges...
			if (len1 > 1) {
				foreach(key, value; getRepeats([row[0], to!long("9".repeat(len1).join(""))], 2)) {
					result += key;
				}
			}
			foreach(key, value; getRepeats([to!long("1" ~ ("0".repeat(len1)).join("")), row[1]], 2)) {
				result += key;
			}
		}
		else {
			foreach(key, value; getRepeats(row, 2)) {
				result += key;
			}
		}

	}

	return result;
}

auto processRange(long[] row) {
	bool[long] resultSet = null;
	long len = to!string(row[1]).length;
	for (int i = 2; i <= len; ++i) {
		// if it's an even divisor
		if (len % i == 0) {
			foreach(key, value; getRepeats(row, i)) {
				resultSet[key] = true;
			}
		}
	}

	long result = 0;
	foreach(key, value; resultSet) {
		result += key;
	}
	return result;
}
auto solve2(Data data) {
	long result = 0;

	foreach (row; data) {
		auto len1 = to!string(row[0]).length;
		auto len2 = to!string(row[1]).length;
		
		if (len1 != len2) {
			// make it two ranges...
			result += processRange([row[0], to!long("9".repeat(len1).join(""))]);
			result += processRange([to!long("1" ~ ("0".repeat(len1)).join("")), row[1]]);
		}
		else {
			result += processRange(row);
		}
	}

	return result;
}

void main() {
	auto testData = parse("test-input");
	
	assert(solve1(testData) == 1227775554, "Solution incorrect");
	assert(solve2(testData) == 4174379265, "Solution incorrect");

	auto data = parse("input");
	writeln(solve1(data));
	writeln(solve2(data));
}
