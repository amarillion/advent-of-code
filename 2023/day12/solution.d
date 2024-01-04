#!/usr/bin/env -S rdmd -I.. -O
module day12.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;

import common.io;

/* 
generates the sequence of '#' and '.' characters that make up a certain arrangement
The idea is that this is more efficient than string concatenation, 
especially for comparisons where you only need to generate until the first mismatch.

But in the end countDynamic is much faster, and this whole function is unimportant.
*/
struct PrintArrangement {
	int pos = -1;
	int stretchRemain = 0;
	int gapRemain = 0;
	char current = '\0';
	int[] stretches;
	int[] gaps;
	int patternLen;
	int i = 0;

	this(int patternLen, int[] stretches, int[] gaps) {
		this.patternLen = patternLen;
		this.stretches = stretches;
		this.gaps = gaps;
		next();
	}

	// generate next character
	private void next() {
		if (gapRemain == 0 && stretchRemain == 0) {
			pos++;
			if (pos < stretches.length) {
				stretchRemain = stretches[pos];
				gapRemain = gaps[pos];
				if (pos > 0) gapRemain += 1; // add compulsory separator.
			}
			else {
				gapRemain = patternLen - 1; // remainder is one long gap.
			}
		}

		if (gapRemain > 0) {
			current = '.';
			gapRemain--;
		}
		else if (stretchRemain > 0) {
			current = '#';
			stretchRemain--;
		}
		i++;
	}

	@property bool empty() { return i > patternLen; }
	@property char front() { return current; }
	void popFront() { next(); }
}

unittest {
	assert(  printArrangement(17, [1,2,3,2,1], [0,0,0,0,0]) == "#.##.###.##.#....");
	assert(compareArrangement("#.##.###.##.#....", [1,2,3,2,1], [0,0,0,0,0]) == true);
	assert(compareArrangement("#.##.###????#....", [1,2,3,2,1], [0,0,0,0,0]) == true);
	assert(compareArrangement("#.##.###....#..##", [1,2,3,2,1], [0,0,0,0,0]) == false);
}

string printArrangement(int patternLen, int[] stretches, int[] gaps) {
	return to!string(PrintArrangement(patternLen, stretches, gaps).array);
}

bool compareArrangement(string pattern, int[] stretches, int[] gaps) {
	foreach(i, current; PrintArrangement(to!int(pattern.length), stretches, gaps).enumerate) {
		if (pattern[i] == '?') continue;
		if (pattern[i] != current) return false;
	}
	return true;
}

bool stretchMatchAt(string pattern, int stretchStart, int stretchLen) {
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
	assert(stretchMatchAt(".###.", 1, 3) == true);
	assert(stretchMatchAt("####.", 1, 3) == false);
	assert(stretchMatchAt(".####", 1, 3) == false);
	assert(stretchMatchAt(".###", 1, 3) == true);
	assert(stretchMatchAt("?###", 1, 3) == true);
	assert(stretchMatchAt(".#?#.", 1, 3) == true);
	assert(stretchMatchAt("?#?#?", 1, 3) == true);
	assert(stretchMatchAt("?#?.?", 1, 3) == false);

	assert(stretchMatchAt("###", 0, 3) == true);
	assert(stretchMatchAt("#?#", 0, 3) == true);
	assert(stretchMatchAt("???", 0, 3) == true);
	assert(stretchMatchAt("##.", 0, 3) == false);
	assert(stretchMatchAt(".##", 0, 3) == false);
	assert(stretchMatchAt("#.#", 0, 3) == false);

	assert(stretchMatchAt("###.", 0, 3) == true);
	assert(stretchMatchAt("###?", 0, 3) == true);
}


// Solution using dynamic programming
// recursively divides into smaller problems.
long countDynamic(Input input) {
	long result = 0;
	if (input.stretches.length == 0) {
		// End of recursion - no more stretches to match.
		// If the remaining pattern is empty, then this counts as 1 valid arrangement.
		// Otherwise there are none.
		result = input.pattern.canFind('#') ? 0 : 1;
	}
	else {
		// pick the middle stretch as a pivot
		int pivot = to!int(input.stretches.length) / 2;

		Input left = Input("", input.stretches[0..pivot]);
		Input right = Input("", input.stretches[pivot+1..$]);

		int leftMin = left.stretches.sum + to!int(left.stretches.length);
		int rightMin = right.stretches.sum + to!int(right.stretches.length);
		int leftMax = to!int(input.pattern.length) - rightMin;

		int pivotStretchLen = input.stretches[pivot];
		for (int y = leftMin; y < (leftMax - pivotStretchLen + 1); ++y) {
			// try the pivotStretch in various positions and compare with the pattern
			bool pivotMatch = stretchMatchAt(input.pattern, y, pivotStretchLen);
			if (!pivotMatch) continue;

			left.pattern = input.pattern[0..max(0, y-1)];
			right.pattern = input.pattern[min($, y+pivotStretchLen+1)..$];

			long countCombo(Input a, Input b) {
				long aa = countDynamic(a);
				long bb = (aa == 0) ? 0 : countDynamic(b); // Big optimization: don't calculate b if a is 0.
				return (aa * bb);
			}

			// Small optimization: calculate the shortest stretch first because it's more likely to be 0 - saves ~10% time.
			result += (leftMin < rightMin ? countCombo(left, right) : countCombo(right, left));
		}
	}
	return result;
}

unittest {
	assert(countDynamic(Input("#?#", [1])) == 0);
	assert(countDynamic(Input(".#?#???", [1,2])) == 1);
	assert(countDynamic(Input(".#?#???????.????#", [1, 2, 3, 2, 1])) == 6);

	assert(countBruteForce(Input(".#?#???????.????#", [1, 2, 3, 2, 1])) == 6);
	
	assert(countDynamic(Input("", [])) == 1);
	assert(countDynamic(Input("#", [])) == 0);
	assert(countDynamic(Input(".", [])) == 1);
	assert(countDynamic(Input("?", [])) == 1);
	assert(countDynamic(Input("#", [1])) == 1);
	assert(countDynamic(Input("#.#", [1, 1])) == 1);
	assert(countDynamic(Input("#.#.#", [1, 1, 1])) == 1);
	assert(countDynamic(Input("??", [1])) == 2);
}

long countBruteForce(Input input) {
	int len = to!int(input.pattern.length);
	int used = input.stretches.sum;
	int gaps = to!int(input.stretches.length) - 1;
	int freedom = len - used - gaps;

	int[] gapArrangement = repeat(0, input.stretches.length).array;
	int count = 0;
	int result = 0;
	do {
		bool valid = compareArrangement(input.pattern, input.stretches, gapArrangement);

		if (valid) {
			string arr = printArrangement(to!int(input.pattern.length), input.stretches, gapArrangement);
			writefln("[%s] #%s: %s: %s", arr, count, gapArrangement, valid);
		}

		if (valid) result++;
		count++;

		int pos = 0; // gap index
		do {
			// increase the first gap until there is no more freedom.
			// if there is no more freedom, set gap back to 0 and increase second gap, and so on.
			if (freedom <= 0) {
				freedom += gapArrangement[pos];
				gapArrangement[pos] = 0;
				pos++;
			}
			if (pos == input.stretches.length) { break; }
			gapArrangement[pos] += 1;
			freedom -= 1;
		} while (freedom < 0);

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
	foreach(string line; readLines(fname)) {
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

void main() {
	auto testData = parse("test-input");
	auto data = parse("input");
	
	auto solve1 = (Input[] patterns) => patterns.map!countDynamic.sum;
	auto solve2 = (Input[] patterns) => patterns.map!unfold.map!countDynamic.sum;

	assert(solve1(testData) == 21);
	assert(solve1(data) == 7090);
	assert(solve2(testData) == 525_152);
	auto result = solve2(data);
	assert(result == 6_792_010_726_878);
	writeln(result); 
}
