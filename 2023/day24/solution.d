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

real sumSq(Data data, vec3d velocity, long firstHitIdx, real firstCrossTime) {
	Line ll;
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
		// writefln("Line A: %s %s", a1, da);
		// writefln("Line B: %s %s", b1, db);
		if (intersect.doIntersect
		) {
			vec2d ta = (intersect.intersection - a1) / da;
			vec2d tb = (intersect.intersection - b1) / db;
			// writefln("%s %s", ta, tb);
			if (ta.x < 0 && tb.x < 0) {
				// writeln("In the past for both");
			}
			else if (ta.x < 0) {
				// writefln("In the past for A");
			} 
			else if (tb.x < 0) {
				// writefln("In the past for B");
			}
			else if (
				intersect.intersection.x >= min && 
				intersect.intersection.y >= min && 
				intersect.intersection.x <= max &&
				intersect.intersection.y <= max
			) {
				// writefln("Intersection inside test area: %s", intersect.intersection);		
				result++;
			}
			else {
				// writefln("Outside test area: %s", intersect.intersection);		
			}
		}
		else {
			// writeln("Lines are parallel");
		}
	}
	return result;
}

/** 
 * 1-Dimensional parameter search
 * TODO: search multiple parameters at the same time (firstCrossTime, velocity.{x,y,z})
 * TODO: open-ended analysis: no need to specify upper bound...
 * TODO: mixed types? Just do long for now...
 */
long parameterSearch(long initialLow, long initialHigh, long desiredPrecision, double delegate(long param) f) {
	long low = initialLow;
	long high = initialHigh;
	long delta = high - low;
	long minParam;
	while (true) {
		double min;
		bool first = true;
		long step = max(desiredPrecision, delta / 10);
		writefln("Searching between %s and %s with step %s", low, high, step);
		for (long param = low; param < high; param += step) {
			double val = f(param);
			if (first || val < min) {
				first = false;
				min = val;
				minParam = param;
				writefln("Lower sumSq %s found at %s", val, param);
			}
		}

		if (step <= desiredPrecision) { break; }

		low = minParam - step;
		high = minParam + step;
		delta = high - low;

		writefln("New search: %s %s %s", low, high, delta);
	}
	return minParam;
}

// this method of parametric fitting only works if we first estimate the parameter within a narrow range (e.g. visually)
// the solve2_improved below is far superior.
long solve2(Data data) {
	
	long crossIdx = 0; // pick any hailstone as basis, doesn't need to be a particular one.
	// we know from analysis that Hailstone #77 is the first to hit, but that info is not used here.

	// auto velocity = vec3d(26, -329, 53); // First guess from visual analysis
	vec3i vv = vec3i(26, -331, 53); // confirmed with parameter search. TODO: should not hardcode this.
	vec3d velocity = vec3d(vv.x, vv.y, vv.z); // convert type

	// search for moment in time when hailstone[crossIdx] hits our line
	long crossTime = parameterSearch(
		0,
		2_000_000_000_000, //TODO: remove need for upper bound...
		1,
		(long crossTime) {
			real val = sumSq(data, velocity, crossIdx, crossTime);
			return to!double(val);
		}
	);

	Line ll;
	ll.velocity = velocity;
	ll.position = 
		data[crossIdx].position + (data[crossIdx].velocity * crossTime) 
		- ll.velocity * crossTime;

	return to!long(ll.position.x) + to!long(ll.position.y) + to!long(ll.position.z);
}

// Gaussian elimination to solve system of equations
// See: https://en.wikipedia.org/wiki/Gaussian_elimination
void gauss(ref real[][] matrix) {
	int pivotRow = 0;
	int pivotCol = 0;
	int nRows = to!int(matrix.length);
	int nCols = to!int(matrix[0].length);
	while (pivotRow < nRows && pivotCol < nCols) {
		real max = 0.0;
		int idxMax = -1;
		for (int i = pivotRow; i < nRows; i++) {
			real cand = abs(matrix[i][pivotCol]);
			if (cand > max) {
				max = cand;
				idxMax = i;
			}
		}
		if (matrix[idxMax][pivotCol] == 0.0) {
			// nothing to pivot in this column
			pivotCol++;
		} else {
			// swap rows idxMax and pivotRow
			swap(matrix[pivotRow], matrix[idxMax]);
			for (int i = pivotRow + 1; i < nRows; i++) {
				// for all lower rows, subtract so that matrix[i][pivotCol] becomes 0
				real factor = matrix[i][pivotCol] / matrix[pivotRow][pivotCol];
				matrix[i][pivotCol] = 0.0;
				for (int j = pivotCol + 1; j < nCols; j++) {
					// only need to go right, to the left it's all zeros anyway
					matrix[i][j] -= factor * matrix[pivotRow][j];
				}
			}
		}
		pivotCol++;
		pivotRow++;
	}
}

long solve2_improved(Data data) {
	// Adapted from solution found on Reddit:
	// https://github.com/dirk527/aoc2021/blob/main/src/aoc2023/Day24.java
	
	real[][] matrix;

	auto hail = data[0];
	matrix.length = 4;
	foreach (i; 0..4) {
		matrix[i].length = 5;
		auto two = data[i + 1];
		matrix[i][0] = hail.position.y - two.position.y;
		matrix[i][1] = two.position.x - hail.position.x;
		matrix[i][2] = two.velocity.y - hail.velocity.y;
		matrix[i][3] = hail.velocity.x - two.velocity.x;
		matrix[i][4] = (hail.position.y * hail.velocity.x - hail.position.x * hail.velocity.y) -
					   (two.position.y * two.velocity.x - two.position.x * two.velocity.y);
	}

	gauss(matrix);

	auto rsy = matrix[3][4] / matrix[3][3];
	auto rsx = (matrix[2][4] - matrix[2][3] * rsy) / matrix[2][2];
	auto rvy = (matrix[1][4] - matrix[1][3] * rsy - matrix[1][2] * rsx) / matrix[1][1];
	auto rvx = (matrix[0][4] - matrix[0][3] * rsy - matrix[0][2] * rsx - matrix[0][1] * rvy) / matrix[0][0];

	auto t1 = (hail.position.x - rsx) / (rvx - hail.velocity.x);
	auto z1 = hail.position.z + t1 * hail.velocity.z;
	auto two = data[1];
	auto t2 = (two.position.x - rsx) / (rvx - two.velocity.x);
	auto z2 = two.position.z + t2 * two.velocity.z;
	auto rvz = (z2 - z1) / (t2 - t1);
	auto rsz = z1 - rvz * t1;

	long result = to!long(rsx + rsy + rsz);
	return result;
}

void main(string[] args)
{
	assert(args.length == 2, "Missing argument: input file");

	auto data = parse(args[1]);

	// parameters depend on whether we are running a test or not. 
	long result = solve1(data, 200000000000000, 400000000000000);
	if (result == 0) {
		// if we don't get any result, we need to apply the other possible parameters.
		result = solve1(data, 7, 27);
	}
	writeln(result);

	// long result2 = solve2(data);
	long result2 = solve2_improved(data);
	writeln(result2);
}