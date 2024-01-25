#!/usr/bin/env -S rdmd -I..
module day23.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;
import std.typecons;

import common.io;
import common.vec;
import common.grid;
import common.cardinal;

alias MyGrid = Grid!(2, char);

MyGrid parse(string fname) {
	return readGrid(new FileReader(fname));
}

Tuple!(Dir, Point)[] getAdjacent1(const MyGrid grid, Point pos) {
	Tuple!(Dir, Point)[] result;
	foreach(dir; [Dir.E, Dir.S, Dir.W, Dir.N]) {
		Point np = pos + DELTA[dir];
		if (grid.inRange(np)) {
			if (grid[np] == '.' || grid[np] == SHORT[dir]) {
				result ~= tuple(dir, np);
			}
		}
	}
	return result;
}

Tuple!(Dir, Point)[] getAdjacent2(const MyGrid grid, Point pos) {
	Tuple!(Dir, Point)[] result;
	foreach(dir; [Dir.E, Dir.S, Dir.W, Dir.N]) {
		Point np = pos + DELTA[dir];
		if (grid.inRange(np)) {
			if (grid[np] != '#') {
				result ~= tuple(dir, np);
			}
		}
	}
	return result;
}

struct Edge {
	Point src;
	Point dest;
	Dir dir;
	int weight;
}
alias Graph = Edge[Dir][Point];

Graph simplify(alias AdjacencyFunc)(Point source, Point end) {
	Graph result;
	Point[] open = [ source, end ];
	bool[Point] isOpened = [ source: true, end: true ];

	while(!open.empty) {
		Point current = open.front;
		open.popFront;

		// writefln("Simplify: examining %s", current);
		foreach(Tuple!(Dir, Point) edge; AdjacencyFunc(current)) {
			Dir dir = edge[0];
			Point next = edge[1];
			// writefln("Following: %s", dir);

			// follow as long as possible
			int weight = 1;
			size_t numLinks;
			bool[Point] visited = [ current: true ];
			while(true) {
				// writefln("Weight %s next %s", weight, next);
				visited[next] = true;
				auto adjacents = AdjacencyFunc(next);
				// writeln(adjacents);
				numLinks = adjacents.length;
				if (numLinks != 2) break;
				
				if (adjacents[0][1] in visited) { 
					next = adjacents[1][1];
				} else { 
					next = adjacents[0][1]; 
				}
				weight++;
			}
			Point dest = next;

			// if (dest !in result) result[dest] = [:];
			// if (current !in result) result[current] = [];
			
			// create two new edges
			result[current][dir] = Edge(current, dest, dir, weight);

			if (dest !in isOpened) {
				open ~= dest;
				isOpened[dest] = true;
			}
		}
		// writeln(result);
		// stdin.readln();
	}

	return result;
}

long longestPath(alias AdjacencyFunc, alias WeightFunc)(Point start, Point end) {
	Tuple!(Dir, Point)[] path;
	
	bool[Point] visited;
	long len = 0;
	long maxLen = 0;
	Point current = start;
	int prevChoice = 0;
	long[] lengths = [];

	while(true) {
		// writefln("Currently at #%s: %s", len, current);

		// forward
		auto options = AdjacencyFunc(current);
		visited[current] = true;
		bool found = false;
		
		// It's important that options are processed in ascending order of direction
		// to make comparison with prevChoice work.
		options.sort!"a[0] < b[0]"();

		foreach(option; options) {
			if (option[0] <= prevChoice) continue;

			// pick first viable option...
			if (option[1] !in visited) {
				path ~= option;
				found = true;
				break;
			}
		}

		if (found) {
			// writefln("Moving forward %s %s", path[$-1][0], path[$-1][1]);
			len += WeightFunc(current, path[$-1][0]);
			current = path[$-1][1];
			prevChoice = 0;

			if (current == end) {
				// save result
				lengths ~= len;
				// writefln("Reached end, added another path: %s", len);
				if (len > maxLen) { maxLen = len; }
			}
		}
		
		if (!found || current == end) {
			// backtrack one step.
			visited.remove(path[$-1][1]);
			Dir prevDir = path[$-1][0];
			prevChoice = path[$-1][0];
			path.popBack();

			if (path.empty) {
				// backtracked all the way to start...
				break;
			}

			current = path[$-1][1];
			len -= WeightFunc(current, prevDir);
			// writefln("Backtracking to %s prevChoice %s", current, prevChoice);
		}

		// stdin.readln();
	}

	return maxLen;
}

auto solve1(MyGrid grid) {
	Point start = Point(1, 0);
	Point end = grid.size - Point(2, 1);

	long result = longestPath!((Point p) => getAdjacent1(grid, p), (Point p, Dir d) => 1)(start, end);
	writeln(result);
	return result;
}

auto solve2(MyGrid grid) {
	Point start = Point(1, 0);
	Point end = grid.size - Point(2, 1);

	auto graph = simplify!((Point p) => getAdjacent2(grid, p))(start, end);
	
	foreach(k, v; graph) {
		writef("%s =>", k);
		foreach(e; v.values) {
			writef(" %s to %s in %s steps;", e.dir, e.dest, e.weight);
		}
		writeln();
	}

	// pre-calculate adjacency data
	Tuple!(Dir, Point)[][Point] adjacent;
	foreach(k, v; graph) {
		adjacent[k] = [];
		foreach(e; v.values) {
			adjacent[k] ~= tuple(e.dir, e.dest);
		}
	}

	long result = longestPath!(
		(Point p) => adjacent[p],
		(Point p, Dir d) => graph[p][d].weight
	)(start, end);
	writeln(result);
	return result;
}

void main() {
	auto testData = parse("test-input");
	assert(solve1(testData) == 94, "Solution incorrect");
	assert(solve2(testData) == 154, "Solution incorrect");
	auto data = parse("input");
	auto result = solve1(data);
	assert(result == 2430);
	result = solve2(data);
	writeln(result);
}
