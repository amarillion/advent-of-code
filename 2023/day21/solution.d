#!/usr/bin/env -S rdmd -I..
module day21.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;

import common.io;
import common.grid;
import common.bfs;
import common.vec;
import common.coordrange;
import common.cardinal;

alias MyGrid = Grid!(2, char);
MyGrid parse(string fname) {
	return readGrid(new FileReader(fname));
}

Point[] getAdjacent(const MyGrid grid, Point pos) {
	Point[] result;
	foreach(Point delta; DELTA.values) {
		Point np = pos + delta;
		Point wrapped = np.wrap(grid.size);
		if (grid[wrapped] != '#') {
			result ~= np;
		}
	}
	return result;
}

Point[] getAdjacentOld(const MyGrid grid, Point pos) {
	Point[] result;
	foreach(Point delta; DELTA.values) {
		Point np = pos + delta;
		if (grid.inRange(np)) {
			if (grid[np] != '#') {
				result ~= np;
			}
		}
	}
	return result;
}

auto getDistanceCounts(MyGrid grid, long steps) {
	long[] cumulativeResults = 0L.repeat(steps + 2).array;

	Point start;
	foreach(Point p; PointRange(grid.size)) {
		if (grid[p] == 'S') {
			start = p;
		}
	}
	auto result = bfs!Point(
		start,
		(Point p, int dist) => dist >= steps,
		(Point p) => getAdjacent(grid, p)
	);
	
	foreach(long dist; result.dist.values) {
		cumulativeResults[dist]++;
	}
	return cumulativeResults;
}

auto solve(long[] cumulativeResults, int steps) {
	long cumulative = 0;
	for(int i = 0; i <= steps; i += 2) {
		cumulative += cumulativeResults[i];
	}
	return cumulative;
}

auto sliceSeries(long[] distanceCounts, long period) {
	long[] unit = [];
	long[][] series = unit.repeat(period).array;
	for(long i = 0; i + 1 < distanceCounts.length; i++) {
		long prev = i < period ? 0 : distanceCounts[i-period];
		series[i % period] ~= distanceCounts[i] - prev;
	}

	// foreach(i, serie; series) {
	// 	writefln("#%s: %s", i, serie);
	// }
	return series;
}

auto extrapolate(long[][] series, long stepCount) {
	long period = series.length;
	long[] distances = repeat(0L, period).array;
	long sum = 0;
	long start = stepCount % 2;
	for(long i = start; i <= stepCount; i += 2) {
		long phase = i % period;
		long iteration = i / period;
		long delta = iteration < series[phase].length ? series[phase][iteration] : series[phase][$-1]; 
		distances[phase] += delta;
		sum += distances[phase];
	}
	// writeln(sum);
	return sum;
}

unittest {
	auto testRaw = parse("test-input");
	long testPeriod = testRaw.size.x + testRaw.size.y;
	auto testData = getDistanceCounts(testRaw, testPeriod * 4);
	auto testSeries = sliceSeries(testData, testPeriod);
	assert(extrapolate(testSeries, 6) == 16, "Solution incorrect");
	assert(extrapolate(testSeries, 10) == 50, "Solution incorrect");
	assert(extrapolate(testSeries, 50) == 1594, "Solution incorrect");
	assert(extrapolate(testSeries, 100) == 6536, "Solution incorrect");
	assert(extrapolate(testSeries, 500) == 167004, "Solution incorrect");
	assert(extrapolate(testSeries, 1000) == 668697, "Solution incorrect");
	assert(extrapolate(testSeries, 5000) == 16733044, "Solution incorrect");
}

void main(string[] args) {
	assert(args.length == 2, "Expected one argument: input file");
	auto raw = parse(args[1]);
	auto period = raw.size.x + raw.size.y;
	auto data = getDistanceCounts(raw, period * 4);
	auto series = sliceSeries(data, period);
	writeln(extrapolate(series, 64));
	writeln(extrapolate(series, 26501365));
}