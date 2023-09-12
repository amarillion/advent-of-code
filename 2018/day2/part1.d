#!/usr/bin/env -S rdmd -I..

import std.stdio;
import std.string;
import std.conv;

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

void main() {

	long numTwos;
	long numThrees;

	foreach (string line; readlines()) {
		const f = letterFrq(line).invert();
		if (2 in f) { numTwos++; }
		if (3 in f) { numThrees++; }
	}	

	writeln("Final result:");
	writeln(numTwos * numThrees);
}
