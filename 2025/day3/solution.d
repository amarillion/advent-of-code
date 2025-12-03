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

		// writeln(row, " ", max);
		result += max;
	}

	return result;
}

auto solve2(Data data) {
	long result = 0;

	foreach (string row; data) {
		// find highest pair of digits for each row
		char[] max = [];

		int remain = 12;
		int pos = 0;
		while (remain > 0) {
			// find highest digits in strlen - remain
			char maxDigit = 0; 
			int maxPos = 0;
			for (int i = pos; i + remain - 1 < row.length; ++i) {
				char digit = row[i];
				if (digit > maxDigit) {
					maxDigit = digit;
					maxPos = i;
				}
			}

			max ~= maxDigit;
			remain--;
			pos = maxPos + 1;
		}

		// writeln(row, " ", max);
		result += to!long(max);
	}

	return result;
}

void main() {
	auto testData = parse("test-input");
	assert(solve1(testData) == 357, "Solution 1 incorrect");
	assert(solve2(testData) == 3121910778619, "Solution 2 incorrect");
	auto data = parse("input");
	writeln(solve1(data));
	writeln(solve2(data));
}
