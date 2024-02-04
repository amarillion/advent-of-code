#!/usr/bin/env -S rdmd -I..
module day24.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;
import std.math;

import common.io;
import common.vec;
import common.pairwise;
import common.coordrange;
import common.geometry;

import std.stdio;
import std.conv;

alias vec3d = vec!(3, real);
alias vec2d = vec!(2, real);

struct Line {
	vec3d position;
	vec3d velocity;
}
alias Data = Line[];

Data parse(string fname) {
	Data result;
	foreach(line; readLines(fname)) {
		vec3d[] coords = line.split(" @ ").map!(
			s => s.split(",").map!strip.map!(to!real).array
		).map!((real[] i) => vec3d(i[0], i[1], i[2])).array;
		result ~= Line(coords[0], coords[1]);
	}
	return result;
}

struct IntersectionResult {
	vec2d intersection;
	bool doIntersect;
}

IntersectionResult lineIntersection(vec2d a1, vec2d da, vec2d b1, vec2d db) {
	IntersectionResult result;
	
	real x1 = a1.x; 
	real x2 = a1.x + da.x;
	real y1 = a1.y;
	real y2 = a1.y + da.y;
	real x3 = b1.x;
	real x4 = b1.x + db.x;
	real y3 = b1.y;
	real y4 = b1.y + db.y;
	
	// source: https://en.wikipedia.org/wiki/Line%E2%80%93line_intersection
	real divisor = (-da.x)*(-db.y) - (-da.y)*(-db.x);
	if (divisor != 0) {
		real x = (((x1 * y2) - (y1 * x2)) * (-db.x) - (-da.x) * ((x3 * y4) - (y3 * x4)));
		x /= divisor;
		real y = (((x1 * y2) - (y1 * x2)) * (-db.y) - (-da.y) * ((x3 * y4) - (y3 * x4)));
		y /= divisor;
		return IntersectionResult(vec2d(x, y), true);
	}
	else {
		return IntersectionResult(vec2d(0, 0), false);
	}

}

real perpendicularDistance(Line a, Line b) {
	auto crossprod = a.velocity.cross(b.velocity);
	real crosslen = crossprod.length();
	if (crosslen == 0) { return real.nan; } // parallel lines!
	auto unitvec = (crossprod / crosslen);
	real result = unitvec.dot(b.position - a.position);
	return result;
}

real sumSq(Data data, vec3d velocity, long firstHitIdx, real firstCrossTime, out Line ll) {
	ll.velocity = velocity;
	ll.position = 
		data[firstHitIdx].position + (data[firstHitIdx].velocity * firstCrossTime) 
		- ll.velocity * firstCrossTime;

	// writefln("Line: %s", ll);

	real result = 0;
	foreach(long idx, Line line; data) {
		real dist = perpendicularDistance(ll, line);
		// writefln("Perpendicular distance with #%s %s = %s", idx, line, dist);
		result += dist * dist;
	}
	return result;
}

auto solve1(Data data, real min, real max) {
	long result = 0;
	foreach(pair; pairwise(data)) {
		vec2d a1 = vec2d(pair[0].position.x, pair[0].position.y);
		vec2d da = vec2d(pair[0].velocity.x, pair[0].velocity.y);

		vec2d b1 = vec2d(pair[1].position.x, pair[1].position.y);
		vec2d db = vec2d(pair[1].velocity.x, pair[1].velocity.y);
		
		auto intersect = lineIntersection(
			a1, da, b1, db
		);
		writefln("Line A: %s %s", a1, da);
		writefln("Line B: %s %s", b1, db);
		if (intersect.doIntersect
		) {
			vec2d ta = (intersect.intersection - a1) / da;
			vec2d tb = (intersect.intersection - b1) / db;
			// writefln("%s %s", ta, tb);
			if (ta.x < 0 && tb.x < 0) {
				writeln("In the past for both");
			}
			else if (ta.x < 0) {
				writefln("In the past for A");
			} 
			else if (tb.x < 0) {
				writefln("In the past for B");
			}
			else if (
				intersect.intersection.x >= min && 
				intersect.intersection.y >= min && 
				intersect.intersection.x <= max &&
				intersect.intersection.y <= max
			) {
				writefln("Intersection inside test area: %s", intersect.intersection);		
				result++;
			}
			else {
				writefln("Outside test area: %s", intersect.intersection);		
			}
		}
		else {
			writeln("Lines are parallel");
		}
	}
	return result;
}

long solve2(Data data) {
	// auto velocity = vec3d(26, -329, 53);
	long firstHitIdx = 77;
	// real firstCrossTime = 59472000000;
	real minVal;
	Line ll;
	Line minLL;
	bool first = true;
	for(real firstCrossTime = 59_816_900_000; firstCrossTime < 59_817_000_000; firstCrossTime += 1) {
		// foreach(vv; CoordRange!vec3i(vec3i(23, -335, 48), vec3i(28, -325, 55))) {
			vec3i vv = vec3i(26, -331, 53);
			vec3d velocity = vec3d(vv.x, vv.y, vv.z);
			real val = sumSq(data, velocity, firstHitIdx, firstCrossTime, ll);
			if (val < minVal || first) {
				minVal = val;
				minLL = ll;
				writefln("Lower sumSq %s found at %s %0.0f", val, vv, firstCrossTime);

				// Lower sumSq 1.93367e+15 found at [26, -331, 53] 59817000000
				// Lower sumSq 1.01236e+13 found at [26, -331, 53] 59816995000
				// Lower sumSq 2.15379e-09 found at [26, -331, 53] 59816994610
				first = false;
			}
		// }
	}
	
	return to!long(minLL.position.x) + to!long(minLL.position.y) + to!long(minLL.position.z);
	// correct answer: 1007148211789625
}


void main(string[] args)
{
	auto testData = parse("test-input");
	writeln(testData);
	assert(solve1(testData, 7, 27) == 2, "Solution incorrect");

	auto data = parse("input");
	auto result = solve1(data, 200000000000000, 400000000000000);
	assert(result == 14799);
	writeln(result);

	writeln(solve2(data));

}