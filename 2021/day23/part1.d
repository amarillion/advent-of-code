module day23.part1;

import common.io;
import common.vec;
import common.dijkstra;
import common.astar;
import std.stdio;
import std.conv;
import std.algorithm;
import std.array;
import std.concurrency;
import std.math;
import std.range;
import std.typecons;
import common.util;
import common.coordrange;
import std.container.binaryheap;
import day23.common;


enum char[int] hallTarget = [
	11: 'A',
	12: 'A',
	13: 'B',
	14: 'B',
	15: 'C',
	16: 'C',
	17: 'D',
	18: 'D'
];

alias State = Pod[8];

void sortPods(ref State state) {
	sort!((a, b) => a.pos < b.pos)(state[]);
}

alias Edge = Tuple!(Move, State);

bool isEndCondition(State state) {
	foreach(Pod p; state) {
		if (p.pos !in hallTarget) return false;
		if (hallTarget[p.pos] != p.type) return false;
	}
	return true;
}

bool targetRoomMismatch(State state, int type) {
	foreach(p; state) {
		if (p.pos !in hallTarget) continue;
		if (hallTarget[p.pos] == type) {
			if (p.type != type) return false;
		}
	}
	return true;
}

enum int[][char] heuristicData = [
	'A': [ 3, 2, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 0, 4, 5, 6, 7, 8, 9 ],
	'B': [ 5, 4, 3, 2, 1, 2, 3, 4, 5, 6, 7, 4, 5, 0, 0, 4, 5, 6, 7 ],
	'C': [ 7, 6, 5, 4, 3, 2, 1, 2, 3, 4, 5, 6, 7, 4, 5, 0, 0, 4, 5 ],
	'D': [ 9, 8, 7, 6, 5, 4, 3, 2, 1, 2, 3, 8, 9, 6, 7, 4, 5, 0, 0 ]
];

// calculate cost of putting everyting in its right state...
int heuristic(State state) {
	int result = 0;
	foreach(pod; state) {
		result += heuristicData[pod.type][pod.pos] * podCosts[pod.type];
	}
	return result;
}

Edge[] validMoves(State state, ref Map map) {
	Edge[] result;
	foreach (int ii, Pod p; state) {
		
		bool isEmpty(int l) {
			foreach(Pod q; state) {
				if (q.pos == l) return false;
			}
			return true;
		}

		Tuple!(int, int)[] adjFunc(int i) {
			return map[i].adjacent.filter!(j => isEmpty(j)).map!(i => tuple(0, i)).array;
		}
		
		// calculate cost for all Edges where this can go...
		auto dijk = dijkstra!(int, int)(p.pos, (int) => false, &adjFunc, (int,int) => podCosts[p.type]);

		foreach(dest; dijk.steps.keys) {
			State newState = state;
			newState[ii] = Pod(p.type, dest);
			// newState.moves = state.moves + 1;
			sortPods(newState);

			bool valid = true;
			// never stop on t-section
			if (map[dest].isForbidden) valid = false;
			// don't move within hallway
			if (p.pos <= 10 && dest <= 10) valid = false;
			// don't move to room unless it's the destination
			if (dest >= 11 && hallTarget[dest] != p.type) valid = false;
			// don't move within a room (NOTE: stricter than needed)
			if (p.pos >= 11 && dest >= 11 && hallTarget[p.pos] == hallTarget[dest]) valid = false;
			// extra condition: destination must not be occupied by mismatches
			if (dest >= 11 && !targetRoomMismatch(newState, p.type)) valid = false;
			if (!valid) continue;

			int cost = dijk.steps[dest].cost;
			result ~= tuple(Move(cost, p, dest), newState);
		}
	}
	return result;
}

void checkMoves(State state, ref Map map) {
	Edge[] moves;
	bool[State] visited;

	void processMoves() {
		foreach (move; moves) {
			// writefln("Can move %s to %s with cost %s. Visited: %s, Heuristic %s", 
			// 	move[0].from, move[0].to, move[0].cost, move[1] in visited ? "true" : "false",
			// 	heuristic(move[1]));
			visited[move[1]] = true;
		}
	}

	// writeln("step 1");
	moves = validMoves(state, map);
	processMoves();
	foreach (i; 2..3) {
		// writefln("Step %s", i);
		moves = moves.filter!(m => m[1] in visited).array;
		moves = moves
			.map!(m => validMoves(m[1], map))
			.join
			.array;
		processMoves();
	}
}

auto solve (string[] lines) {
	auto data = parse(lines);

	State state = to!(Pod[8])(data.initialPods);
	// writefln("State: %s", state);
	sortPods(state);
	// writefln("State: %s", state);
	int minCost = int.max;

	// checkMoves(state);
	State goal = [
		Pod('A', 11), Pod('A', 12), Pod('B', 13), Pod('B', 14), 
		Pod('C', 15), Pod('C', 16), Pod('D', 17), Pod('D', 18)
	];
	assert(goal.isEndCondition);

	auto astarResult = astar!(State, Move)(
		state, 
		s => s == goal, 
		s => s.validMoves(data.map), 
		(Edge m) => m[0].cost,
		s => s.heuristic
	);
	auto current = goal;
	assert(current in astarResult.prev);
	return astarResult.prev[goal].cost;
}

unittest {
	auto dist = [1:50, 2:40, 3:30, 4:20, 5:10];
	auto heap = heapify!((a,b) => dist[a] > dist[b])([3]);

	assert(heap.dup.canFind(5) == false);
	
	assert(heap.front == 3);
	heap.insert(4);
	assert(heap.front == 4);
	heap.insert(2);
	assert(heap.front == 4);
	heap.insert(1);
	assert(heap.front == 4);
	heap.insert(5);
	assert(heap.front == 5);

	assert(heap.dup.canFind(5) == true);

	heap.popFront;
	// writeln(heap);
	assert(heap.front == 4);
	heap.popFront;
	assert(heap.front == 3);
	heap.popFront;
	assert(heap.front == 2);
	// writeln(heap);

	int[4] ints = [2, 3, 1, 0];
	sort(ints[]);
	assert(ints == [0, 1, 2, 3]);
}

