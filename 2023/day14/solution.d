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

auto solve1(const Data cgrid) {
	Data grid = cgrid.dup;

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
				// transpose, examine in the other direction to ensure rocks are moved in the right order
				pos = grid.size - pos - 1;
			}

			if(grid[pos] == 'O') {
				move(grid, pos, delta);
			}
		}
	}
}

/** 
 * Semi-generic cycle detection class.
 * Collect occurences in a map, and calculate differences between last occurences
 * Then do frequency analysis to return the most frequent cycle.
 */
class CycleDetector(T) {
	long[T] lastOccurence;
	long[T] differences;
	void add(long pos, T val) {
		if (val in lastOccurence) {
			differences[val] = pos - lastOccurence[val];
		}
		lastOccurence[val] = pos;
	}

	long detect() {
		// writeln(differences);
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
auto solve2(const Data cgrid) {
	Data grid = cgrid.dup; // defensive copy
	long remain = 1_000_000_000;

	// stabilize loop first 200 times...
	foreach(int i; 0..100) {
		spinCycle(grid);
		remain--;
	}

	// now start detecting cycles...
	auto detector = new CycleDetector!long();
	for(long i = 0; i < 200; ++i) {
		spinCycle(grid);
		remain--;
		detector.add(i, countLoad(grid));
	}
	long cycleLen = detector.detect();

	// last few spins to make the cycle match up...
	foreach(i; 0..(remain % cycleLen)) {
		spinCycle(grid);
	}

	return countLoad(grid);
}

void main(string[] args) {
	assert(args.length == 2, "Expected one argument: input file");
	auto data = parse(args[1]);
	writeln(solve1(data));
	writeln(solve2(data));
}
