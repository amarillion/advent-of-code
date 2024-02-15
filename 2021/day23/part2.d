module day23.part2;

import std.stdio;
import std.conv;
import std.algorithm;
import std.array;
import std.concurrency;
import std.math;
import std.range;
import std.typecons;
import std.container.binaryheap;

import common.io;
import common.vec;
import common.util;
import common.grid;
import common.coordrange;
import common.astar;

import day23.common;

enum char[int] hallTarget = [
	11: 'A',
	12: 'A',
	13: 'A',
	14: 'A',
	15: 'B',
	16: 'B',
	17: 'B',
	18: 'B',
	19: 'C',
	20: 'C',
	21: 'C',
	22: 'C',
	23: 'D',
	24: 'D',
	25: 'D',
	26: 'D',
];

alias State = Pod[16];

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
		// for all the pods that are in a room
		if (p.pos !in hallTarget) continue;
		// for all the pods that are in the room of the target type
		if (hallTarget[p.pos] != type) continue;
		
		// is that pod of the right type?
		if (p.type != type) return false;
	}
	return true;
}

enum int[][char] heuristicData = [
	'A': [ 3, 2, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 0, 0, 0, 4, 5, 6, 7, 6, 7, 8, 9, 8, 9,10,11 ],
	'B': [ 5, 4, 3, 2, 1, 2, 3, 4, 5, 6, 7, 4, 5, 6, 7, 0, 0, 0, 0, 4, 5, 6, 7, 6, 7, 8, 9 ],
	'C': [ 7, 6, 5, 4, 3, 2, 1, 2, 3, 4, 5, 6, 7, 8, 9, 4, 5, 6, 7, 0, 0, 0, 0, 4, 5, 6, 7 ],
	'D': [ 9, 8, 7, 6, 5, 4, 3, 2, 1, 2, 3, 8, 9,10,11, 6, 7, 8, 9, 4, 5, 6, 7, 0, 0, 0, 0 ]
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
	// create a position map
	char[int] occupancy;
	foreach (Pod p; state) {
		occupancy[p.pos] = p.type;
	}

	foreach (int ii, Pod p; state) {

		Tuple!(int, int)[] adjFunc(int i) {
			return map[i].adjacent.filter!(j => j !in occupancy).map!(i => tuple(0, i)).array;
		}
		
		// calculate cost for all Edges where this can go...
		auto astarResult = astar!(int, int)(p.pos, (int n) => false, &adjFunc, (Tuple!(int,int)) => podCosts[p.type]);

		foreach(dest; astarResult.prev.keys) {
			State newState = state;
			newState[ii] = Pod(p.type, dest);
			sortPods(newState);

			// never stop on t-section
			if (map[dest].isForbidden) continue;
			// don't move within hallway
			if (p.pos <= 10 && dest <= 10) continue;
			// don't move to room unless it's the destination
			if (dest >= 11 && hallTarget[dest] != p.type) continue;
			// destination must not contain mismatches.
			if (dest >= 11 && !targetRoomMismatch(newState, p.type)) continue;
			// EXTRA CONDITION to reduce search space: don't move within a room
			if (p.pos >= 11 && dest >= 11 && hallTarget[p.pos] == hallTarget[dest]) continue;
			// EXTRA CONDITION to reduce search space: if we're in a room, check that the next spot isn't empty
			if (dest >= 11 && ((dest-11) % 4 < 3) && ((dest + 1) !in occupancy)) continue;
			
			int cost = astarResult.prev[dest].cost;
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
				// move[0].from, move[0].to, move[0].cost, move[1] in visited ? "true" : "false",
				// heuristic(move[1]));
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

	State state = to!(Pod[16])(data.initialPods);
	sortPods(state);
	
	// checkMoves(state);
	State goal = [
		Pod('A', 11), Pod('A', 12), Pod('A', 13), Pod('A', 14), 
		Pod('B', 15), Pod('B', 16), Pod('B', 17), Pod('B', 18),
		Pod('C', 19), Pod('C', 20), Pod('C', 21), Pod('C', 22), 
		Pod('D', 23), Pod('D', 24), Pod('D', 25), Pod('D', 26),
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
