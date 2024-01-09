#!/usr/bin/env -S rdmd -I..
module day17.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;
import std.typecons;

import common.io;
import common.grid;
import common.vec;
import common.cardinal;
import common.dijkstra;

alias MyGrid = Grid!(2, int);

struct Node {
	Point pos;
	Dir dir;
	int stretch;
}

Tuple!(Dir,Node)[] getAdjacent(int minStretch, int maxStretch)(const MyGrid grid, const Node node) {
	Tuple!(Dir, Node)[] result;

	foreach(dir; [Dir.E, Dir.N, Dir.W, Dir.S]) {
		if (dir == REVERSE[node.dir]) continue; // can't reverse
		// may not turn before minStretch, EXCEPT ON THE STARTING NODE - this cost me 2 hours to fix...
		if (node.pos != Point(0, 0) && node.stretch < (minStretch - 1) && dir != node.dir) continue;
		if (node.stretch >= (maxStretch - 1) && dir == node.dir) continue; // must turn after maxStretch
		Point np = node.pos + DELTA[dir];
		if (!grid.inRange(np)) continue;
		result ~= tuple(dir, Node(np, dir, dir == node.dir ? node.stretch + 1 : 0));
	}
	return result;
}

MyGrid parse(string fname) {
	return readGrid!((char ch) => to!int(to!string(ch)))(new FileReader(fname));
}

auto solve(int minStretch, int maxStretch)(const MyGrid grid) {
	Node start = Node(Point(0, 0), Dir.E, 0);
	Point endPos = grid.size - 1;
	auto result = dijkstra(start,
		(Node n) => (n.pos == endPos && n.stretch >= (minStretch - 1)),
		(Node n) => getAdjacent!(minStretch, maxStretch)(grid, n),
		(Node n) => grid[n.pos] 
	);
	
	Node current = result.dest;
	auto view = new Grid!(2, char)(grid.size.x, grid.size.y, '.');

	while (current != start) {
		view[current.pos] = SHORT[current.dir]; 
		// writefln("%s %s", current, result.dist[current]);
		current = result.prev[current];
	}

	writeln(view.format(""), "\n");
	long totalDist = result.dist[result.dest];
	writeln(totalDist);
	return totalDist;
}

void main() {
	auto testData = parse("test-input");

	alias solve1 = solve!(0, 3);
	alias solve2 = solve!(4, 10);

	assert(solve1(testData) == 102, "Solution incorrect");
	assert(solve2(testData) == 94, "Solution incorrect");

	auto testData2 = parse("test-input2");
	assert(solve2(testData2) == 71, "Solution incorrect");

	auto data = parse("input");
	assert(solve1(data) == 665);
	auto result = solve2(data);
	assert(result == 809);
}
