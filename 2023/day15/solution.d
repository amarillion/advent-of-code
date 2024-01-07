#!/usr/bin/env -S rdmd -I..
module day15.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;

import common.io;

alias Data = string;
Data parse(string fname) {
	string[] lines = readLines(fname);
	return lines[0];
}

auto hash(string input) {
	ubyte current = 0;
	foreach(char ch; input) {
		current += to!ubyte(ch);
		current *= 17;
	}
	return current;
}

auto solve1(Data data) {
	long result = 0;
	foreach(param; data.split(",")) {
		result += hash(param);
	}
	return result;
}

void main() {
	auto testData = parse("test-input");
	assert(solve1(testData) == 1320, "Solution incorrect");

	auto data = parse("input");
	auto result = solve1(data);
	assert(result == 521_341);
	writeln(result);
}
