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

bool stretchMatchAt(string pattern, int stretchStart, int stretchLen) {
	// writefln("Calling stretchMatchAt('%s', %s, %s)", pattern, stretchStart, stretchLen);
	// check the pivot stretch against the pattern;
	int y = stretchStart;
	int y2 = y + stretchLen;

	if (y > 0 && pattern[y-1] == '#') return false;

	for (int i = 0; i < stretchLen; ++i) {
		if (pattern[y + i] == '.') return false;
	}

	if (y2 < pattern.length && pattern[y2] == '#') return false;

	return true;
}

unittest {
	assert(stretchMatchAt("###", 0, 3) == true);
	assert(stretchMatchAt("#?#", 0, 3) == true);
	assert(stretchMatchAt("???", 0, 3) == true);
	assert(stretchMatchAt("##.", 0, 3) == false);
	assert(stretchMatchAt(".##", 0, 3) == false);
	assert(stretchMatchAt("#.#", 0, 3) == false);

	assert(stretchMatchAt("###.", 0, 3) == true);
	assert(stretchMatchAt("###?", 0, 3) == true);

	assert(stretchMatchAt(".###", 1, 3) == true);
	assert(stretchMatchAt("?###", 1, 3) == true);
	assert(stretchMatchAt("####", 1, 3) == false);
	assert(stretchMatchAt(".###.", 1, 3) == true);
	assert(stretchMatchAt(".#?#.", 1, 3) == true);
	assert(stretchMatchAt("?#?#?", 1, 3) == true);
	assert(stretchMatchAt("?#?.?", 1, 3) == false);
}

long countPartial(Input input, int ofst = 0, int _totalLen = -1) {
	int totalLen = _totalLen < 0 ? to!int(input.pattern.length) : _totalLen;
	long result = 0;
	if (input.stretches.length == 0) {
		// If the remaining pattern is empty, then this counts as 1 arrangement.
		result = 1;
		for (int k = 0; k < input.pattern.length; ++k) {
			if (input.pattern[k] == '#') {
				result = 0;
				break;
			}
		}
	}
	else {
		int pivot = to!int(input.stretches.length) / 2;

		Input left = Input("", input.stretches[0..pivot]);
		Input right = Input("", input.stretches[pivot+1..$]);

		int leftMin = left.stretches.sum + to!int(left.stretches.length);
		int rightMin = right.stretches.sum + to!int(right.stretches.length);
		int leftMax = to!int(input.pattern.length) - rightMin;

		// writefln("leftMin: %s %s %s rightMin: %s %s %s, leftMax: %s", leftMin, left.stretches.sum, left.stretches.length, rightMin, right.stretches.sum, right.stretches.length, leftMax);
		// writefln("countPartial: %s    %s", patStr, input.stretches);
			
		int pivotStretchLen = input.stretches[pivot];
		for (int y = leftMin; y < (leftMax - pivotStretchLen + 1); ++y) {
			bool pivotMatch = stretchMatchAt(input.pattern, y, pivotStretchLen);
			// writefln("y: %s, pivotMatch: %s", y, pivotMatch);
			if (!pivotMatch) continue;

			int y2 = y + pivotStretchLen;

			left.pattern = input.pattern[0..max(0, y-1)];
			right.pattern = input.pattern[min($, y2+1)..$];

			// stretches.length serves as recursive break.
			long leftCount = countPartial(left, ofst, totalLen);
			long rightCount = countPartial(right, ofst + y2 + 1, totalLen);
			// writefln("  leftCount: %s rightCount: %s", leftCount, rightCount);
			result += (leftCount * rightCount);
		}
	}
	// char[] patStr = repeat('_', ofst).array ~ input.pattern ~ repeat('_', max(0, totalLen - to!int(input.pattern.length) - ofst)).array;
	// writefln("countPartial: %s    %s = %s", patStr, input.stretches, result);
	return result;
}

unittest {
	
	assert(countPartial(Input("#?#", [1])) == 0);
	
	assert(countPartial(Input(".#?#???", [1,2])) == 1);
	
	assert(countPartial(Input(".#?#???????.????#", [1, 2, 3, 2, 1])) == 6);
	
	assert(countArrangements(Input(".#?#???????.????#", [1, 2, 3, 2, 1])) == 6);
	assert(countPartial(Input("", [])) == 1);
	assert(countPartial(Input("#", [])) == 0);
	assert(countPartial(Input(".", [])) == 1);
	assert(countPartial(Input("?", [])) == 1);
	assert(countPartial(Input("#", [1])) == 1);
	assert(countPartial(Input("#.#", [1, 1])) == 1);
	assert(countPartial(Input("#.#.#", [1, 1, 1])) == 1);
	assert(countPartial(Input("??", [1])) == 2);
}

long countArrangements2(Input input) {
	long result = countPartial(input, 0, to!int(input.pattern.length));
	// long result2 = countArrangements(input);
	writefln("[%s] %s %s", input.pattern, input.stretches, result);
	// assert(result == result2);
	return result;
}

long countArrangements(Input input) {

	int len = to!int(input.pattern.length);
	int used = input.stretches.sum;
	int gaps = to!int(input.stretches.length) - 1;
	int freedom = len - used - gaps;
	// writefln("[%s] %s %s %s %s %s", input.pattern, input.stretches, len, used, gaps, freedom);

	int[] arrangement = repeat(0, input.stretches.length).array;
	int remain = freedom;
	int count = 0;
	int result = 0;
	do {
		string arr = printArrangement(len, input.stretches, arrangement);
		// string arr2 = printArrangement2(input.pattern, input.stretches, arrangement);
		bool valid = compareArrangement(input.pattern, arr);
		// bool valid = printAndCompare(input.pattern, input.stretches, arrangement);
		if (valid) {
			writefln("[%s] #%s: %s: %s, remain: %s", arr, count, arrangement, valid, remain);
		}

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

	writefln("[%s] %s %s %s %s", input.pattern, input.stretches, freedom, count, result);
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
	return patterns.map!countArrangements2.sum;
}

auto solve2(Input[] patterns) {
	return patterns.map!unfold.map!countArrangements2.sum;
}

void main() {
	auto testData = parse("test-input");
	auto data = parse("input");
	
	assert(solve1(testData) == 21);
	assert(solve1(data) == 7090);
	assert(solve2(testData) == 525_152);
	auto result = solve2(data);
	writeln(result); // 6792010726878
}
