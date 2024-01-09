#!/usr/bin/env -S rdmd -I..
module day17.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;
import std.typecons;
import std.container.binaryheap;

import common.io;
import common.grid;
import common.vec;
import common.cardinal;

alias MyGrid = Grid!(2, int);

struct Node {
	Point pos;
	Dir dir;
	int straightRemain;
}

Tuple!(Dir,Node)[] getAdjacent(const MyGrid grid, const Node node) {
	Tuple!(Dir, Node)[] result;

	foreach(dir; [Dir.E, Dir.N, Dir.W, Dir.S]) {
		if (node.straightRemain == 0 && dir == node.dir) continue; // can't move 3 steps continuous
		if (dir == REVERSE[node.dir]) continue; // can't reverse
		Point np = node.pos + DELTA[dir];
		if (!grid.inRange(np)) continue;
		result ~= tuple(dir, Node(np, dir, dir == node.dir ? node.straightRemain - 1 : 2));
	}
	return result;
}

Tuple!(Dir,Node)[] getAdjacent2(const MyGrid grid, const Node node) {
	Tuple!(Dir, Node)[] result;

	foreach(dir; [Dir.E, Dir.N, Dir.W, Dir.S]) {
		if (dir == REVERSE[node.dir]) continue; // can't reverse
		// can't turn first four...
		if (node.straightRemain >= 7 && dir != node.dir) continue;
		// must turn after 10...
		if (node.straightRemain == 0 && dir == node.dir) continue; // can't move 3 steps continuous
		Point np = node.pos + DELTA[dir];
		if (!grid.inRange(np)) continue;
		result ~= tuple(dir, Node(np, dir, dir == node.dir ? node.straightRemain - 1 : 9));
	}
	return result;
}


int dijkstra(N)(N source, bool delegate(N) isDest, Tuple!(Dir,N)[] delegate(N) getAdjacent, int delegate(N) getWeight) {
	// Mark all nodes unvisited. Create a set of all the unvisited nodes called the unvisited set.
	// Assign to every node a tentative distance value: set it to zero for our initial node and to infinity for all other nodes. Set the initial node as current.[13]
	int[N] dist = [ source: 0 ];
	bool[N] visited;
	N[N] prev;
	Node firstDest;

	// priority queue	
	auto open = heapify!((a, b) => dist[a] > dist[b])([ source ]);

	// int maxIterations = 1000;
	// int i = maxIterations;
	while (open.length > 0) {
		N current = open.front;
		open.popFront;
		
		// check adjacents, calculate distance, or  - if it already had one - check if new path is shorter
		foreach(pair; getAdjacent(current)) {
			Node sibling = pair[1];

			if (!(sibling in visited)) {
				int alt = dist[current] + getWeight(sibling);
				
				// any node that is !visited and has a distance assigned should be in open set.
				// if (!open.canFind(sibling)) open.insert(sibling); // may be already in there

				int oldDist = sibling in dist ? dist[sibling] : int.max;

				if (alt < oldDist) {
					// set or update distance
					dist[sibling] = alt;
					// build back-tracking map
					prev[sibling] = current;

					open.insert(sibling);
				}
			}
		}

		// A visited node will never be checked again.
		visited[current] = true;

		if (isDest(current)) {
			firstDest = current;
			break;	
		}
	}

	N current = firstDest;
	while (current != source) {
		writefln("%s %s", current, dist[current]);
		current = prev[current];
	}
	return dist[firstDest];
}

MyGrid parse(string fname) {
	return readGrid!((char ch) => to!int(to!string(ch)))(new FileReader(fname));
}

auto solve1(const MyGrid grid) {
	Node start = Node(Point(0, 0), Dir.E, 3);
	Point endPos = grid.size - 1;
	auto result = dijkstra(start,
		(Node n) => n.pos == endPos,
		(Node n) => getAdjacent(grid, n),
		(Node n) => grid[n.pos] 
	);
	writeln(result);
	return result;
}

auto solve2(const MyGrid grid) {
	Node start = Node(Point(0, 0), Dir.E, 10);
	Point endPos = grid.size - 1;
	auto result = dijkstra(start,
		(Node n) => (n.pos == endPos && n.straightRemain <= 6),
		(Node n) => getAdjacent2(grid, n),
		(Node n) => grid[n.pos] 
	);
	writeln(result);
	return result;
}

void main() {
	auto testData = parse("test-input");
	assert(solve1(testData) == 102, "Solution incorrect");
	assert(solve2(testData) == 94, "Solution incorrect");

	auto testData2 = parse("test-input2");
	assert(solve2(testData2) == 71, "Solution incorrect");

	auto data = parse("input");
	assert(solve1(data) == 665);
	auto result = solve2(data);
	assert(result == 809);
	writeln(result);
}
