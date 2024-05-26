#!/usr/bin/env -S rdmd -I..
module day5.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;

import common.io;
import core.stdc.ctype;
import core.stdcpp.array;

alias Data = string;
Data parse(string fname) {
	string[] lines = readLines(fname);
	return lines[0];
}

auto solve1(Data data) {
	int pos = 0;
	ulong len = data.length;
	writeln(data[0..min(80, len)]);
	while(pos < len-1) {
		char c = data[pos];
		bool oppositeParity = data[pos].isupper != data[pos + 1].isupper;
		bool same = tolower(c) == tolower(data[pos + 1]);
		if (same && oppositeParity) {
			// remove the pair
			data = data[0..pos] ~ data[min(len, pos + 2)..$];
			pos = max(0, pos - 1);
			len -= 2;
			// writeln(data[max(0, pos - 40)..min(len, pos + 40)]);
		}
		else {
			pos++;
		}
	}
	return len;
}

auto solve2(Data data) {
	ulong minLen = data.length;
	for(char c = 'a'; c <= 'z'; c++) {
		string filtered = to!string(data.filter!(x => tolower(x) != c));
		ulong len = solve1(filtered);
		if (len < minLen) {
			minLen = len;
		}
	}
	return minLen;
}

void main(string[] args) {
	assert(args.length == 2, "Expecting 1 argument: input file");
	auto data = parse(args[1]);
	writeln(solve1(data));
	writeln(solve2(data));
}
