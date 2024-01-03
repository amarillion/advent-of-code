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

bool printAndCompare(string pattern, int[] stretches, int[] gaps) {
	int pos = 0;
	int stretchRemain = stretches[0];
	int gapRemain = gaps[0];
	for(int i = 0; i < pattern.length; i++) {
		// generate current characters
		if (gapRemain == 0 && stretchRemain == 0) {
			pos++;
			if (pos < stretches.length) {
				stretchRemain = stretches[pos];
				gapRemain = gaps[pos] + 1; // +1, don't forget the minimum gap size.
			}
			else {
				// remainder is a gap.
				gapRemain = to!int(pattern.length) - 1;
			}
		}

		char current;
		if (gapRemain > 0) {
			current = '.';
			gapRemain--;
		}
		else if (stretchRemain > 0) {
			current = '#';
			stretchRemain--;
		}
				
		// compare
		if (pattern[i] == '?') continue;
		if (pattern[i] != current) return false;
	}
	return true;
}

string printArrangement2(string pattern, int[] stretches, int[] gaps) {
	int pos = 0;
	int stretchRemain = stretches[0];
	int gapRemain = gaps[0];
	char[] result = [];
	for(int i = 0; i < pattern.length; i++) {
		// generate current characters
		if (gapRemain == 0 && stretchRemain == 0) {
			pos++;
			if (pos < stretches.length) {
				stretchRemain = stretches[pos];
				gapRemain = gaps[pos] + 1; // +1, don't forget the minimum gap size.
			}
			else {
				// remainder is a gap.
				gapRemain = to!int(pattern.length) - 1;
			}
		}

		char current;
		if (gapRemain > 0) {
			current = '.';
			gapRemain--;
		}
		else if (stretchRemain > 0) {
			current = '#';
			stretchRemain--;
		}
		
		result ~= current;
	}
	return to!string(result);
}

long countArrangements(Input input) {

	int len = to!int(input.pattern.length);
	int used = input.stretches.sum;
	int gaps = to!int(input.stretches.length) - 1;
	int freedom = len - used - gaps;
	
	writefln("[%s] %s %s %s %s %s", input.pattern, input.stretches, len, used, gaps, freedom);

	int[] arrangement = repeat(0, input.stretches.length).array;
	int remain = freedom;
	int count = 0;
	int result = 0;
	do {
		// string arr = printArrangement(len, input.stretches, arrangement);
		// string arr2 = printArrangement2(input.pattern, input.stretches, arrangement);
		// bool valid = compareArrangement(input.pattern, arr);
		bool valid = printAndCompare(input.pattern, input.stretches, arrangement);
		// writefln("[%s] <%s> #%s: %s: %s, remain: %s", arr2, arr, count, arrangement, valid, remain);

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
			if (pos == input.stretches.length) { break; }
			arrangement[pos] += 1;
			remain -= 1;
		} while (remain < 0);

		if (pos == input.stretches.length) { break; } // end condition
		
	}
	while(true);

	return result;
}

struct Input {
	string pattern;
	int[] stretches;
}

auto parse(string fname) {
	Input[] result;
	string[] lines = readLines(fname);
	foreach(string line; lines) {
		string[] fields = line.split(" ");
		int[] stretches = fields[1].split(",").map!(to!int).array;
		result ~= Input(fields[0], stretches);
	}
	return result;
}

Input unfold(Input input) {
	string unfoldedPattern = repeat(input.pattern, 5).join("?");
	int[] unfoldedStretches = repeat(input.stretches, 5).join;
	return Input(unfoldedPattern, unfoldedStretches);
}

auto solve1(Input[] patterns) {
	return patterns.map!countArrangements.sum;
}

auto solve2(Input[] patterns) {
	return patterns.map!unfold.map!countArrangements.sum;
}

void main() {
	auto testData = parse("test-input");
	auto data = parse("input");
	
	
	assert(solve1(testData) == 21);
	assert(solve1(data) == 7090);
	
	// assert(solve2(testData) == 525_152);
	auto result = solve2(data);
	writeln(result);
}
