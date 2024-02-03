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
import common.box;

alias Block = Cuboid!int;
alias Blocks = Block[];

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
		result ~= Block(p1, p2 - p1 + 1);
	}
	return result;
}

int[] dropBlock(Block original, int id, ref int[vec3i] collisionMap) {
	bool[int] underlings;
	Block block = original;
	bool falling = true;
	while(falling) {
		Block newBlock =  block;
		newBlock.pos.z--;

		foreach(vec3i pp; newBlock.coordrange) {
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
	foreach(vec3i pp; block.coordrange) {
		assert(pp !in collisionMap, 
			format("Position already occupied by block %s at %s while checking block %s", collisionMap[pp], pp, id)
		);
		collisionMap[pp] = id;
	}

	// writefln("Block %s dropped to %s, supported by %s", id, block.pos.z, underlings.keys);
	// writeln(collisionMap);
	return underlings.keys;
}

int countTransitiveSupport(int id, int[][int] supportedBy, int[][int] isSupporting) {
	bool[int] disintegrating = [ id: true ];
	bool[int] visited;
	int[] open = [ id ];
	while (!open.empty) {
		auto current = open.front;
		open.popFront;

		if (current in visited) {
			continue;
		}
		visited[current] = true;

		if (current in isSupporting) {
			foreach(overling; isSupporting[current]) {
				bool canFall = true;
				foreach(underling; supportedBy[overling]) {
					if (underling !in disintegrating) {
						// writefln("Block %s above %s is still supported by %s", overling, current, underling);
						canFall = false;
						break;
					}
				}
				if (canFall) {
					// writefln("Falling %s causes %s to fall", current, overling);
					disintegrating[overling] = true;
					open ~= overling;
				}
			}
		}
	}
	return to!int(disintegrating.length) - 1;
}

auto solve(Blocks blocks) {
	sort!"a.pos.z < b.pos.z"(blocks);
	int[vec3i] collisionMap;
	int[][int] isSupporting;
	int[][int] supportedBy;

	foreach(long i, Block block; blocks) {
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
	long result2 = 0;
	foreach(long i; 0..blocks.length) {
		int ii = to!int(i);
		int count = countTransitiveSupport(ii, supportedBy, isSupporting);
		if (count == 0) {
			result++;
		}
		else {
			result2 += count;
		}
	}

	return [ result, result2 ];
}

void main(string[] args) {
	assert(args.length == 2, "Expected one argument: input file");
	auto data = parse(args[1]);
	writeln(solve(data));
}
/*
	auto testData = parse("test-input");
	assert(solve1(testData) == [ 5, 7 ], "Solution incorrect");

	auto data = parse("input");
	auto result = solve1(data);
	// assert(result == 430);
	writeln(result);
}
*/