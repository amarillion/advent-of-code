module day23.part2;

import std.stdio;
import std.conv;
import std.algorithm;
import std.array;
import std.concurrency;
import std.math;
import std.range;
import std.typecons;

import common.io;
import common.vec;
import common.astar;
import common.util;
import common.coordrange;

import day23.common;

alias State = Pod[16];
alias Edge = Tuple!(Move, State);

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
			if (!map[dest].isHallway && map[dest].type != p.type) continue;
			// destination must not contain mismatches.
			if (!map[dest].isHallway && !targetRoomMismatch(newState, p.type, map)) continue;
			// EXTRA CONDITION to reduce search space: don't move within a room
			if (!map[p.pos].isHallway && !map[dest].isHallway && map[p.pos].type == map[dest].type) continue;
			// EXTRA CONDITION to reduce search space: if we're in a room, check that the next spot isn't empty
			if (dest >= 11 && ((dest-11) % 4 < 3) && ((dest + 1) !in occupancy)) continue;
			
			int cost = astarResult.prev[dest].cost;
			result ~= tuple(Move(cost, p, dest), newState);
		}
	}
	return result;
}

auto solve (string[] lines) {
	auto data = parse(lines);

	State state = to!(Pod[16])(data.initialPods);
	sortPods(state);
	
	// checkMoves(state);
	State goal = to!(Pod[16])(data.goalPods);
	assert(goal.isEndCondition(data.map));

	auto astarResult = astar!(State, Move)(
		state, 
		s => s == goal, 
		s => s.validMoves(data.map), 
		(Edge m) => m[0].cost,
		s => s.heuristic(data.map)
	);
	auto current = goal;
	assert(current in astarResult.prev);
	return astarResult.prev[goal].cost;
}

