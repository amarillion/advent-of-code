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

long charDelta(string a, string b) {
	assert(a.length == b.length);
	long delta = 0;
	for(size_t i = 0; i < a.length; ++i) {
		if (a[i] != b[i]) { delta++; }
	}
	return delta;
}

void main() {

	string[] lines = readlines();

	foreach(a; lines) {
		foreach (b; lines) {
			if (charDelta(a, b) == 1) {
				writefln("1: %s\n2: %s", a, b);
			}
		}
	}
}
