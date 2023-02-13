#!/usr/bin/env -S rdmd -I..

import common.io;
import std.stdio;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.range;

auto solve(string data) {
	int enterBasement = 0;
	int floor = 0;
	int pos = 0;

	foreach(char ch; data) {
		if (ch == '(') {
			floor++;
		}
		else if (ch == ')') {
			floor--;
		}
		else {
			continue;
		}
		pos++;
		if (enterBasement == 0 && floor < 0) {
			enterBasement = pos;
		}
	}

	return [
		floor, enterBasement
	];
}

void main() {
	assert(solve("()())") == [-1, 5]);
	
	string data = readLines("input").join;
	writeln(solve(data));
}
