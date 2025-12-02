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

auto numDigits(long value) {
	return to!string(value).length;
}

auto simplifyRanges(Data data) {
	// simplify so that each range starts and ends with the same number of digits.
	Data result;
	foreach (row; data) {
		auto len1 = numDigits(row[0]);
		auto len2 = numDigits(row[1]);
		
		if (len1 != len2) {
			long pivot = to!long("9".repeat(len1).join(""));
			result ~= [row[0], pivot];
			result ~= [pivot + 1, row[1]];
		}
		else {
			result ~= row;
		}
	}
	return result;
}

auto getRepeats(long[] range, int numParts = 2) {
	bool[long] result = null;

	auto len = numDigits(range[1]);
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
		auto len = numDigits(row[0]);
		if (len > 1) {
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
		result += processRange(row);
	}

	return result;
}

void main() {
	auto testData = simplifyRanges(parse("test-input"));
		
	assert(solve1(testData) == 1227775554, "Solution incorrect");
	assert(solve2(testData) == 4174379265, "Solution incorrect");

	auto data = simplifyRanges(parse("input"));
	writeln(solve1(data));
	writeln(solve2(data));
}
