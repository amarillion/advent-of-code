#!/usr/bin/env -S rdmd -I..
module day2.solution;

import std.stdio;
import std.string;
import std.conv;

import common.io;

string[] readlines() {
	string[] result;
	string line;
	while ((line = readln()) !is null) {
		result ~= chomp(line);
	}
	return result;
}

long[char] letterFrq(string line) {
	long[char] result;
	foreach (char c; line) {
		if (c in result) {
			result[c]++;
		}
		else {
			result[c] = 1;
		}
	}
	return result;
}

T[U] invert(U, T)(U[T] map) {
	T[U] result;
	foreach(k, v; map) {
		result[v] = k;
	}
	return result;
}

long charDelta(string a, string b) {
	assert(a.length == b.length);
	long delta = 0;
	for(size_t i = 0; i < a.length; ++i) {
		if (a[i] != b[i]) { delta++; }
	}
	return delta;
}

long solve1(string[] lines) {
	long numTwos;
	long numThrees;

	foreach (string line; lines) {
		const f = letterFrq(line).invert();
		if (2 in f) { numTwos++; }
		if (3 in f) { numThrees++; }
	}	
	return numTwos * numThrees;
}

string solve2(string[] lines) {
	foreach(a; lines) {
		foreach (b; lines) {
			if (charDelta(a, b) == 1) {
				char[] result;
				for(size_t i = 0; i < a.length; ++i) {
					if (a[i] == b[i]) { result ~= a[i]; }
				}
				return to!string(result);
			}
		}
	}
	return "No solution found";
}

void main(string[] args) {
	assert(args.length == 2, "Usage: day2 <input file>");
	string[] lines = readLines(args[1]);

	writeln(solve1(lines));
	writeln(solve2(lines));
}
