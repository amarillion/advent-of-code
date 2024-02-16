module day23.part1;

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
import common.dijkstra;
import common.astar;
import common.util;
import common.coordrange;

import day23.common;

alias State = Pod[8];
alias Edge = Tuple!(Move, State);

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
			if (!map[dest].isHallway && map[dest].type != p.type) valid = false;
			// don't move within a room (NOTE: stricter than needed)
			if (!map[p.pos].isHallway && !map[dest].isHallway && map[p.pos].type == map[dest].type) valid = false;
			// extra condition: destination must not be occupied by mismatches
			if (dest >= 11 && !targetRoomMismatch(newState, p.type, map)) valid = false;
			if (!valid) continue;

			int cost = dijk.steps[dest].cost;
			result ~= tuple(Move(cost, p, dest), newState);
		}
	}
	return result;
}

auto solve (string[] lines) {
	auto data = parse(lines);

	State state = to!(Pod[8])(data.initialPods);
	// writefln("State: %s", state);
	sortPods(state);
	// writefln("State: %s", state);
	int minCost = int.max;

	State goal = to!(Pod[8])(data.goalPods);
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

