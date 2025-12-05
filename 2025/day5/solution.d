#!/usr/bin/env -S rdmd -I..
module day5.solution;

import std.file;
import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;

import common.box;

struct Range(T) {
	T start;
	T size;

	this(T start, T size) {
		this.start = start;
		this.size = size;
	}

	bool contains(T val) {
		return val >= start && val < (start + size);
	}

	bool overlaps(Range other) {
		return (start < other.start + other.size && start + size > other.start);
	}
}


Range!T[] merge(T)(Range!T a, Range!T b) {
	if (a.overlaps(b)) {
		auto start = min(a.start, b.start);
		auto end = max(a.start + a.size, b.start + b.size);
		return [Range!T(start, end - start)];
	}
	else {
		return [a, b];
	}
}

struct Data {
	Range!long[] ranges;
	long[] ingredients;
}

Data parse(string fname) {
	string[] paragraphs = readText(fname).stripRight.split("\n\n");

	Data result;
	foreach (string range; paragraphs[0].split('\n')) {
		long[] data = range.split('-').map!(to!long).array;
		result.ranges ~= Range!long(data[0], data[1] - data[0] + 1);
	}

	result.ingredients = paragraphs[1].split('\n').map!(to!long).array;
	return result;
}

auto solve1(Data data) {
	long result = 0;
	foreach(i; data.ingredients) {
		auto fresh = false;
		foreach(r; data.ranges) {
			if (r.contains(i)) {
				fresh = true;
				break;
			}
		}
		if (fresh) {
			result++;
		}
	}
	return result;
}

auto solve2(Data data) {

	Range!long[] sorted = sort!"a.start < b.start"(data.ranges).array;
	
	long prevSize;

	Range!long[] result = [];
	// writeln(sorted);
	do {
		prevSize = sorted.length;
		result = [];
		auto current = sorted.front();
		sorted.popFront();
		while(!sorted.empty) {
			auto next = sorted.front();
			sorted.popFront();
			auto merged = merge(current, next);
			if (merged.length > 1) {
				result ~= merged[0..$-1];
			}
			current = merged[$-1];
		}
		result ~= current;
		// writeln(result);
		sorted = result;
	} while (sorted.length < prevSize);

	long sum = 0;
	foreach(r; result) {
		sum += r.size;
	}
	return sum;
}

void main(string[] args) {
	assert(args.length == 2, "Expected one argument: input file");
	auto data = parse(args[1]);
	writeln(solve1(data));
	writeln(solve2(data));
}

