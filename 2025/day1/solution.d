#!/usr/bin/env -S rdmd -I..
module day1.solution;

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
	
	int pos = 50;
	foreach (line; data) {
		auto dir = line[0];
		auto remain = to!int(line[1..$]);
		
		switch(dir) {
			case 'L': pos -= remain; break;
			case 'R': pos += remain; break;
			default: assert(false);
		}

		while(pos < 0) {
			pos += 100;
		}
		while (pos >= 100) {
			pos -= 100;
		}

		if (pos == 0) {
			result += 1;
		}

		writefln("Turn %s %s => %s. Result: %s", dir, remain, pos, result);

	}

	return result;
}

auto solve2(Data data) {
	long result = 0;
	
	int pos = 50;
	foreach (line; data) {
		auto dir = line[0];
		auto remain = to!int(line[1..$]);
		
		while (remain > 100) {
			remain -= 100;
			result += 1;
		}

		switch(dir) {
			case 'L': 
				if (pos > 0 && remain > pos) {
					result += 1;
				}
				pos = (pos + 100 - remain) % 100; 
				break;
			case 'R': 
				if (pos > 0 && pos + remain > 100) {
					result += 1;
				}
				pos = (pos + remain) % 100;
				break;
			default: assert(false);
		}

		if (pos == 0) {
			result += 1;
		}

		writefln("Turn %s %s => %s. Result: %s", dir, remain, pos, result);

	}

	return result;
}

void main() {
	
	auto testData = parse("test-input");
	assert(solve1(testData) == 3, "Solution 1 incorrect");
	assert(solve2(testData) == 6, "Solution 2 incorrect");

	auto data = parse("input");
	auto result = solve1(data);
	writeln(result);

	auto result2 = solve2(data);
	writeln(result2);

}
