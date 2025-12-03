#!/usr/bin/env -S rdmd -I..
module day3.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;

import common.io;

alias Data = string[];
Data parse(string fname) {
	string[] lines = readLines(fname);
	return lines;
}

auto solve1(Data data) {
	long result = 0;

	foreach (string row; data) {
		// find highest pair of digits for each row
		int max = 0;
		for (int i = 0; i + 1 < row.length; ++i) {
			for (int j = i + 1; j < row.length; ++j) {
				int total = 10 * (row[i] - '0') + (row[j] - '0');
				if (total > max) {
					max = total;
				}
			}
		}

		writeln(row, " ", max);
		result += max;
	}

	return result;
}
 
void main() {
	auto testData = parse("test-input");
	assert(solve1(testData) == 357, "Solution incorrect");

	auto data = parse("input");
	auto result = solve1(data);
	// assert(result == 1);
	writeln(result);
}
