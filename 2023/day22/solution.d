#!/usr/bin/env -S rdmd -I..
module day22.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;

import common.io;
import common.vec;
import common.coordrange;

struct Rect {
	vec3i pos;
	vec3i size;
}

alias Blocks = Rect[];
Blocks parse(string fname) {
	Blocks result;
	foreach(line; readLines(fname)) {
		string[] fields = line.split("~");
		vec3i parseCoord(string input) {
			int[] ii = input.split(",").map!(to!int).array;
			return vec3i(ii[0], ii[1], ii[2]);
		}
		vec3i p1 = parseCoord(fields[0]);
		vec3i p2 = parseCoord(fields[1]);
		result ~= Rect(p1, p2 - p1 + 1);
	}
	return result;
}

int[] dropBlock(Rect original, int id, ref int[vec3i] collisionMap) {
	bool[int] underlings;
	Rect block = original;
	bool falling = true;
	while(falling) {
		Rect newBlock =  block;
		newBlock.pos.z--;

		foreach(vec3i pp; CoordRange!vec3i(newBlock.pos, newBlock.pos + newBlock.size)) {
			if (pp in collisionMap) {
				underlings[collisionMap[pp]] = true;
				falling = false;
			}
		}
		
		if (newBlock.pos.z < 1) {
			// we've hit the ground;
			falling = false;
		}

		if (falling) {
			block = newBlock;
		}
	}
	
	// solidify
	foreach(vec3i pp; CoordRange!vec3i(block.pos, block.pos + block.size)) {
		assert(pp !in collisionMap, 
			format("Position already occupied by block %s at %s while checking block %s", collisionMap[pp], pp, id)
		);
		collisionMap[pp] = id;
	}

	writefln("Block %s dropped to %s, supported by %s", id, block.pos.z, underlings.keys);
	// writeln(collisionMap);
	return underlings.keys;
}

auto solve1(Blocks blocks) {
	sort!"a.pos.z < b.pos.z"(blocks);
	int[vec3i] collisionMap;
	int[][int] isSupporting;
	int[][int] supportedBy;

	foreach(long i, Rect block; blocks) {
		int id = to!int(i);
		int[] underlings = dropBlock(block, id, collisionMap);
		supportedBy[id] = underlings;
		foreach(underling; underlings) {
			if(underling !in isSupporting) {
				isSupporting[underling] = [ id ];
			}
			else {
				isSupporting[underling] ~= id;
			}
		}
	}

	// writeln("isSupporting\n", isSupporting);
	// writeln("supportedBy\n", supportedBy);

	long result = 0;
	foreach(long i; 0..blocks.length) {
		int ii = to!int(i);
		bool canBeRemoved = true;
		if (ii in isSupporting) {
			foreach(overling; isSupporting[ii]) {
				if (supportedBy[overling].length == 1) {
					canBeRemoved = false;
					break;
				}
			}
		}
		if (canBeRemoved) {
			result++;
		}
	}

	return result;
}

void main() {
	auto testData = parse("test-input");
	assert(solve1(testData) == 5, "Solution incorrect");

	auto data = parse("input");
	auto result = solve1(data);
	assert(result == 430);
	writeln(result);
}
