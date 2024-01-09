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

int dijkstra(N)(N source, bool delegate(N) isDest, Tuple!(Dir,N)[] delegate(N) getAdjacent, int delegate(N) getWeight) {
	// Mark all nodes unvisited. Create a set of all the unvisited nodes called the unvisited set.
	// Assign to every node a tentative distance value: set it to zero for our initial node and to infinity for all other nodes. Set the initial node as current.[13]
	int[N] dist = [ source: 0 ];
	bool[N] visited;
	N[N] prev;
	Node firstDest;

	// TODO: more efficient to use a priority queue here
	const(N)[] open = [ source ];

	// int maxIterations = 1000;
	// int i = maxIterations;
	while (open.length > 0) {
		
		// i--; // 0 -> -1 means Infinite.
		// if (i == 0) break;

		// extract the element from Q with the lowest dist. Open is modified in-place.
		// TODO: optionally use PriorityQueue
		// O(N^2) like this, O(log N) with priority queue. But in my tests, priority queues only start pulling ahead in large graphs
		N minElt;
		bool found = false;
		foreach (elt; open) {
			if (!found || dist[elt] < dist[minElt]) {
				minElt = elt;
				found = true;
			}
		}
		if (found) open = open.filter!(i => i != minElt).array;
		
		N current = minElt;
		// check adjacents, calculate distance, or  - if it already had one - check if new path is shorter
		foreach(pair; getAdjacent(current)) {
			Node sibling = pair[1];

			if (!(sibling in visited)) {
				int alt = dist[current] + getWeight(sibling);
				
				// any node that is !visited and has a distance assigned should be in open set.
				if (!open.canFind(sibling)) open ~= sibling; // may be already in there

				int oldDist = sibling in dist ? dist[sibling] : int.max;

				if (alt < oldDist) {
					// set or update distance
					dist[sibling] = alt;
					// build back-tracking map
					prev[sibling] = current;
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

void main() {
	auto testData = parse("test-input");
	assert(solve1(testData) == 102, "Solution incorrect");

	auto data = parse("input");
	auto result = solve1(data);
	assert(result == 665);
	writeln(result);
}
