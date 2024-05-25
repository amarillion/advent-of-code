#!/usr/bin/env -S rdmd -I..

import common.io;
import common.vec;
import std.stdio;
import std.conv;
import std.algorithm;
import std.array;
import std.concurrency;
import std.math;
import std.range;
import common.util;
import common.coordrange;
import std.bigint;
import common.box : Box, intersections, measure;

alias Cuboid = Box!(3, long);

unittest {
	/*
	on x=10..12,y=10..12,z=10..12
	on x=11..13,y=11..13,z=11..13
	off x=9..11,y=9..11,z=9..11
	on x=10..10,y=10..10,z=10..10
	*/	
	Cuboid[] list = [];
	list = merge(list, Cuboid(vec3i(10,10,10), vec3i(3,3,3)), true);
	assert(list.map!measure.sum == 27);
	
	list = merge(list, Cuboid(vec3i(11,11,11), vec3i(3,3,3)), true);
	assert(list.map!measure.sum == 27 + 19);

	list = merge(list, Cuboid(vec3i(9,9,9), vec3i(3,3,3)), false);
	assert(list.map!measure.sum == 27 + 19 - 8);

	list = merge(list, Cuboid(vec3i(10,10,10), vec3i(1,1,1)), true);
	assert(list.map!measure.sum == 27 + 19 - 8 + 1);
}

Cuboid[][] breakup(Cuboid[] list, Cuboid cc) {
	Cuboid[] aList = list.dup;
	Cuboid[] bList = [ cc ];

	Cuboid[] aResult;
	Cuboid[] bResult;
	Cuboid[] overlapping;

	//TODO: this algorithm can probably be optimized
	while (aList.length > 0) {
		Cuboid a = aList.front;
		aList.popFront;
		bool overlapFound = false;
		Cuboid[] newBlist = [];
		foreach(b; bList) {
			if (a.overlaps(b)) {
				assert(!overlapFound); // shouldn't find two overlaps in one scan
				Cuboid[][] i = intersections(a, b);
				
				aList ~= i[0];
				overlapping ~= i[1];
				newBlist = bList.filter!(x => x != b).array ~ i[2];
				overlapFound = true;
				break;
			}
		}
		if (overlapFound) {
			bList = newBlist;
		}
		else {
			aResult ~= a;
		}
	}
	bResult = bList;
	
	long[] v = [
		list.map!measure.sum,
		cc.measure,

		aResult.map!measure.sum,
		overlapping.map!measure.sum,
		bResult.map!measure.sum,
	];

	// sanity check: volumes of inputs and outputs should match
	assert(v[0] == v[2] + v[3]);
	assert(v[1] == v[3] + v[4]);
	assert(v[0] + v[1] == v[2] + 2 * v[3] + v[4]);
	return [
		aResult, overlapping, bResult
	];
}

auto merge(Cuboid[] list, Cuboid c, bool add) {
	Cuboid[][] brokenUp = breakup(list, c);
	Cuboid[] result;
	if (add) {
		result = brokenUp[0] ~ brokenUp[1] ~ brokenUp[2];
	}
	else {
		result = brokenUp[0];
	}
	return result;
}

struct Record {
	Cuboid cuboid;
	bool turnOn;
}

Record[] parse(string fname) {
	return readLines(fname).map!((string line) {
		string[] fields = line.split(" ");
		bool turnOn = fields[0] == "on";
		int[][] coords = fields[1].split(",").map!(s => s["x=".length..$].split("..").map!(to!int).array).array;
		sort(coords[0]);
		sort(coords[1]);
		sort(coords[2]);
		auto p1 = vec!(3, long)(coords[0][0], coords[1][0], coords[2][0]);
		auto p2 = vec!(3, long)(coords[0][1], coords[1][1], coords[2][1]);
		auto cuboid = Cuboid(p1, (p2 - p1) + 1);
		return Record(cuboid, turnOn);
	}).array;
}

auto calc (Record[] records) {
	Cuboid[] onCubes = [];

	foreach(record; records) {
		onCubes = merge(onCubes, record.cuboid, record.turnOn);
	}

	return onCubes.map!measure.sum;
}

auto solve(string fname) {
	Cuboid fifty = Cuboid(vec!(3, long)(-50, -50, -50), vec!(3, long)(100, 100, 100));
	Record[] records = parse(fname);
	return [ 
		// part 1: only cuboids within 50 from origin
		calc(records.filter!(r => fifty.contains(r.cuboid.pos)).array),
		// part 2: all cuboids
		calc(records)
	];
}

void main(string[] args) {
	assert(args.length == 2, "Argument expected: input file");
	writeln (solve(args[1]));
}
