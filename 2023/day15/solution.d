#!/usr/bin/env -S rdmd -I..
module day15.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;
import std.regex;

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

struct Lens {
	string label;
	int focalLength;

	string toString() const {
		return "[%s %s]".format(label, focalLength);
	}
}

auto byHash(Lens[] lenses) {
	Lens[][ubyte] hashmap;
	foreach(ubyte i; 0..256) {
		hashmap[i] = [];
	}

	foreach(lens; lenses) {
		ubyte code = hash(lens.label);
		hashmap[code] ~= lens;
	}

	return hashmap;
}

void print(Lens[][ubyte] hashmap) {
	foreach(ubyte i; 0..256) {
		if(hashmap[i].empty) continue;
		writefln("Box %s: %s", i, hashmap[i]);
	}
}

auto calculate(Lens[][ubyte] hashmap) {
	long result;
	foreach(ubyte i; 0..256) {
		long boxResult = 0;
		foreach(idx, lens; hashmap[i]) {
			boxResult += ((to!int(i) + 1) * (idx + 1) * lens.focalLength);
		}
		// writefln("Box %s: %s -> %s", i, boxResult, result + boxResult);
		result += boxResult;
	}
	return result;
}

auto solve2(Data instructions) {
	Lens[] lensOrder;
	foreach(instr; instructions.split(",")) {
		// writefln("After \"%s\"", instr);
		auto m1 = instr.matchFirst(regex(r"^(\w+)=(\d+)$"));
		auto m2 = instr.matchFirst(regex(r"^(\w+)-$"));

		if (!m1.empty) {
			string label = m1[1];
			int focalLength = to!int(m1[2]);
			bool found = false;
			foreach(ref lens; lensOrder) {
				if (lens.label == label) {
					lens.focalLength = focalLength;
					found = true;
				}
			}
			if (!found) {
				lensOrder ~= Lens(label, focalLength);
			}
		}
		else if(!m2.empty) {
			string label = m2[1];
			lensOrder = lensOrder.filter!(i => i.label != label).array;
		}
		// print(byHash(lensOrder));
	}

	auto hashmap = byHash(lensOrder);	
	return calculate(hashmap);
}

void main(string[] args) {
	assert(args.length == 2, "Expected one argument: input file");
	auto data = parse(args[1]);
	writeln(solve1(data));
	writeln(solve2(data));
}
