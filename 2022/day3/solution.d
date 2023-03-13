#!/usr/bin/env -S rdmd -I..

import std.stdio;
import std.file;
import std.range;
import std.string;

/**
In groups of items, find an item that occurs in each group.
Ends with an assertion failure if no such item can be found.
*/
T findCommonElement(T)(T[][] groups) {
	int[T] found;
	int i = 1;
	foreach(group; groups) {
		foreach(item; group) {
			if (item !in found) { found[item] = 0; }
			if (found[item] == i - 1) found[item] = i;
			if (found[item] == groups.length) {
				return item;
			}
		}
		i++;
	}
	assert(false); // raise exception, no duplicate found
}

int part1(string[] lines) {
	int sum = 0;
	foreach (line; lines) {
		// TODO: use evenChunks... -> complains that string has no length property.
		// auto parts = line.evenChunks(2);
		string[] parts = [ line[0..$/2], line[$/2..$] ];
		char item = findCommonElement(parts);
		int foundIndex = item >= 'a' ? (item - 'a' + 1) : (item - 'A' + 27);
		sum += foundIndex;
	}
	return sum;
}

int part2(string[] lines) {
	auto chunks = lines.chunks(3);
	int sum = 0;
	foreach(chunk; chunks) {
		char item = findCommonElement(chunk);
		int foundIndex = item >= 'a' ? (item - 'a' + 1) : (item - 'A' + 27);
		sum += foundIndex;
	}
	return sum;
}

int[] solve(string fname) {
	string[] lines = readText(fname).stripRight.split('\n');
	return [ part1(lines), part2(lines) ];
}

void main() {
	assert(solve("test-input") == [157, 70]);
	writeln(solve("input"));
}
