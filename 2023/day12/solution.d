#!/usr/bin/env -S rdmd -I..
module day12.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;

import common.io;

string printArrangement(int len, int[] stretches, int[] gaps) {
	char[] result;
	assert(stretches.length == gaps.length);
	for(int i = 0; i < stretches.length; ++i) {
		if (i != 0) result ~= '.';
		result ~= repeat('.', gaps[i]).array;
		result ~= repeat('#', stretches[i]).array;
	}
	result ~= repeat('.', len - result.length).array;
	return to!string(result);
}

bool compareArrangement(string pattern, string arrangement) {
	for(int i = 0; i < pattern.length; ++i) {
		char a = pattern[i];
		if (a == '?') continue;
		char b = i < arrangement.length ? arrangement[i] : '.';
		if (a != b) return false;
	}
	return true;
}

long countArrangements(string pattern, int[] stretches) {

	int len = to!int(pattern.length);
	int used = stretches.sum;
	int freedom = len - used - (to!int(stretches.length) - 1);
	
	writefln("[%s] %s %s", pattern, stretches, freedom);

	int[] arrangement = repeat(0, stretches.length).array;
	int remain = freedom;
	int count = 0;
	int result = 0;
	do {
		string arr = printArrangement(len, stretches, arrangement);
		bool valid = compareArrangement(pattern, arr);
		// writefln("[%s] #%s: %s: %s, remain: %s", arr, count, arrangement, valid, remain);

		if (valid) result++;
		count++;

		int pos = 0;
		do {
			// writefln("%s %s %s", arrangement, pos, remain);
			if (remain <= 0) {
				remain += arrangement[pos];
				arrangement[pos] = 0;
				pos++;
			}
			if (pos == stretches.length) { break; }
			arrangement[pos] += 1;
			remain -= 1;
		} while (remain < 0);

		if (pos == stretches.length) { break; } // end condition
		
	}
	while(true);

	return result;
}
auto solve(string fname) {
	string[] lines = readLines(fname);
	
	long sum = 0;

	foreach(string line; lines) {
		string[] fields = line.split(" ");
		int[] stretches = fields[1].split(",").map!(to!int).array;
		sum += countArrangements(fields[0], stretches);
	}

	return [
		sum
	];
}

void main() {
	assert(solve("test-input") == [ 21 ], "Incorrect solution");
	auto result = solve("input");
	assert(result == [ 7090 ]);
	writeln(result);
}
