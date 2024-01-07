#!/usr/bin/env -S rdmd -I..
module day14.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;

import common.io;
import common.grid;
import common.vec;
import common.coordrange;

alias Data = Grid!(2, char);
Data parse(string fname) {
	return readGrid(new FileReader(fname));
}

void move(Data grid, Point pos, Point delta) {
	Point current = pos;
	while(true) {
		Point np = current + delta;
		if (!grid.inRange(np)) break;
		if (grid[np] != '.') break;
		grid[current] = '.';
		grid[np] = 'O';
		current = np;
	}
}

long countLoad(Data grid) {
	long result = 0;
	foreach(Point p; PointRange(grid.size)) {
		if(grid[p] == 'O') {
			long val = grid.size.y - p.y;
			result += val;
		}
	}
	return result;
}

auto solve1(Data grid) {
	// move all 'O's up
	foreach(Point p; PointRange(grid.size)) {
		if(grid[p] == 'O') {
			move(grid, p, Point(0,-1));
		}
	}

	// count positions of O's	
	return countLoad(grid);
}

void spinCycle(Data grid) {
	Point[] dirs = [Point(0, -1), Point(-1, 0), Point(0, 1), Point(1, 0)];
	foreach(Point delta; dirs) {
		foreach(Point p; PointRange(grid.size)) {
			
			Point pos = p;
			if (delta.y > 0 || delta.x > 0) {
				// examine in the other direction...
				pos = grid.size - pos - 1;
			}

			if(grid[pos] == 'O') {
				move(grid, pos, delta);
			}
		}
	}
}


class CycleDetector {
	long[long] lastOccurence;
	long[long] differences;
	void add(long pos, long val) {
		if (val in lastOccurence) {
			differences[val] = pos - lastOccurence[val];
		}
		lastOccurence[val] = pos;
	}

	long detect() {
		writeln(differences);
		long[long] frqMap;
		foreach(k, v; differences) {
			long prev = v in frqMap ? frqMap[v] : 0;
			frqMap[v] = prev + 1;
		}
		long maxFrq = 0;
		long maxPeriod = 0;
		foreach(k, v; frqMap) {
			if (v > maxFrq) {
				maxFrq = v;
				maxPeriod = k;
			}
		}
		return maxPeriod;
	}
}

long detectCycle(Data grid) {
	auto detector = new CycleDetector();
	for(long i = 0; i < 10_000; ++i) {
		spinCycle(grid);
		detector.add(i, countLoad(grid));
	}
	return detector.detect();
}

// we know cycle of test-input is 7...
// cycle of input is ...
auto solve2(Data grid, long cycleLen) {
	long remain = 1_000_000_000;

	// stabilize loop first 1000 times...
	foreach(int i; 0..1000) {
		spinCycle(grid);
		remain--;
	}

	foreach(i; 0..(remain % cycleLen)) {
		spinCycle(grid);
	}

	return countLoad(grid);
}

void main() {
	// auto testData = parse("test-input");
	// assert(solve1(testData) == 136, "Solution incorrect");
	// long testCycle = detectCycle(testData);
	// assert(testCycle == 7); // empirical observation
	// testData = parse("test-input");
	// assert(solve2(testData, testCycle) == 64, "Solution incorrect");

	auto data = parse("input");
	// assert(solve1(data) == 106_990);

	long cycle = detectCycle(data);
	assert(cycle == 39); // empirical observation
	data = parse("input");
	auto result = solve2(data, cycle);
	// assert(result == 106_990);
	writeln(result);
}
