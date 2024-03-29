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
import common.box : Box;

alias Cuboid = Box!(3, int);

Cuboid[] bisect(Cuboid a, int pos, int dim) {
	vec3i p1 = a.pos;
	vec3i p2 = a.pos + a.size;

	// doesn't bisect, return unchanged.
	if (pos <= p1.val[dim] || pos >= p2.val[dim]) {
		return [ a ];
	}

	vec3i s1 = a.size;
	s1.val[dim] = pos - p1.val[dim];
	vec3i s2 = a.size;
	s2.val[dim] = p2.val[dim] - pos;
	
	vec3i p15 = p1;
	p15.val[dim] = pos;

	assert(s1.x > 0 && s1.y > 0 && s1.z > 0);
	assert(s2.x > 0 && s2.y > 0 && s2.z > 0);
	return [
		Cuboid(p1, s1),
		Cuboid(p15, s2)
	];
}

// splits a & b in three lists: parts of a, overlapping, and parts of b.
// returns variable number of cubes, could be up to 27
Cuboid[][] intersections(Cuboid a, Cuboid b) {
	Cuboid[] aSplits = [ a ];
	Cuboid[] bSplits = [ b ];

	vec3i a1 = a.pos;
	vec3i a2 = a.pos + a.size;
	vec3i b1 = b.pos;
	vec3i b2 = b.pos + b.size;

	for (int dim = 0; dim < 3; ++dim) {
		aSplits = aSplits.map!(q => q.overlaps(b) ? q.bisect(b1.val[dim], dim).array : [ q ]).join.array;
		aSplits = aSplits.map!(q => q.overlaps(b) ? q.bisect(b2.val[dim], dim).array : [ q ]).join.array;
		bSplits = bSplits.map!(q => q.overlaps(a) ? q.bisect(a1.val[dim], dim).array : [ q ]).join.array;
		bSplits = bSplits.map!(q => q.overlaps(a) ? q.bisect(a2.val[dim], dim).array : [ q ]).join.array;
	}

	// determine overlapping
	sort (aSplits);
	sort (bSplits);
	Cuboid[] overlapping = aSplits.setIntersection(bSplits).array;
	aSplits = aSplits.setDifference(overlapping).array;
	bSplits = bSplits.setDifference(overlapping).array;
	return [
		aSplits,
		overlapping,
		bSplits
	];
}

long volume(Cuboid a) {
	return to!long(a.size.x) * to!long(a.size.y) * to!long(a.size.z);
}

unittest {	
	Cuboid a = Cuboid(vec3i(0, 0, 0), vec3i(5, 3, 4));
	Cuboid b = Cuboid(vec3i(-2, 1, 2), vec3i(5, 4, 3));
	Cuboid c = Cuboid(vec3i(1,1,1), vec3i(1,1,1));

	assert(a.volume == 60);
	assert(b.volume == 60);
	assert(c.volume == 1);
	
	vec3i p1 = vec3i(2, 1, 2);
	vec3i p2 = vec3i(8,0,0);

	assert (intersections(a, b) == [
		[
			Cuboid(vec3i(0,0,0), vec3i(3,1,4)), 
			Cuboid(vec3i(3,0,0), vec3i(2,3,4)), 
			Cuboid(vec3i(0,1,0), vec3i(3,2,2)), 
		],
		[
			Cuboid(vec3i(0,1,2), vec3i(3,2,2)),
		],
		[
			Cuboid(vec3i(-2, 1, 2), vec3i(2, 4, 3)), 
			Cuboid(vec3i( 0, 3, 2), vec3i(3, 2, 3)), 
			Cuboid(vec3i( 0, 1, 4), vec3i(3, 2, 1)), 
		],
	]);

	assert (intersections(Cuboid(vec3i(0), vec3i(3,3,1)), Cuboid(vec3i(1,1,0), vec3i(1))) == [
		[
			Cuboid(vec3i(0,0,0), vec3i(1, 3, 1)), 
			Cuboid(vec3i(1,0,0), vec3i(1, 1, 1)), 
			Cuboid(vec3i(2,0,0), vec3i(1, 3, 1)), 
			Cuboid(vec3i(1,2,0), vec3i(1, 1, 1)), 
		],
		[
			Cuboid(vec3i(1,1,0), vec3i(1, 1, 1)),
		],
		[],
	]);

	assert(intersections(
		Cuboid(vec3i(5,0,0), vec3i(1, 10, 1)), 
		Cuboid(vec3i(0,5,0), vec3i(10, 1, 1)), 
	) == [
		[
			Cuboid(vec3i(5,0,0), vec3i(1, 5, 1)),
			Cuboid(vec3i(5,6,0), vec3i(1, 4, 1)),
		],
		[
			Cuboid(vec3i(5,5,0), vec3i(1, 1, 1)),
		],
		[
			Cuboid(vec3i(0,5,0), vec3i(5, 1, 1)),
			Cuboid(vec3i(6,5,0), vec3i(4, 1, 1)),
		]
	]);

	/*
	on x=10..12,y=10..12,z=10..12
	on x=11..13,y=11..13,z=11..13
	off x=9..11,y=9..11,z=9..11
	on x=10..10,y=10..10,z=10..10
	*/	
	Cuboid[] list = [];
	list = merge(list, Cuboid(vec3i(10,10,10), vec3i(3,3,3)), true);
	assert(list.map!volume.sum == 27);
	
	list = merge(list, Cuboid(vec3i(11,11,11), vec3i(3,3,3)), true);
	assert(list.map!volume.sum == 27 + 19);

	list = merge(list, Cuboid(vec3i(9,9,9), vec3i(3,3,3)), false);
	assert(list.map!volume.sum == 27 + 19 - 8);

	list = merge(list, Cuboid(vec3i(10,10,10), vec3i(1,1,1)), true);
	assert(list.map!volume.sum == 27 + 19 - 8 + 1);
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
		list.map!volume.sum,
		cc.volume,

		aResult.map!volume.sum,
		overlapping.map!volume.sum,
		bResult.map!volume.sum,
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
		vec3i p1 = vec3i(coords[0][0], coords[1][0], coords[2][0]);
		vec3i p2 = vec3i(coords[0][1], coords[1][1], coords[2][1]);
		auto cuboid = Cuboid(p1, (p2 - p1) + 1);
		return Record(cuboid, turnOn);
	}).array;
}

auto calc (Record[] records) {
	Cuboid[] onCubes = [];

	foreach(record; records) {
		onCubes = merge(onCubes, record.cuboid, record.turnOn);
	}

	return onCubes.map!volume.sum;
}

auto solve(string fname) {
	Cuboid fifty = Cuboid(vec3i(-50, -50, -50), vec3i(100, 100, 100));
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
