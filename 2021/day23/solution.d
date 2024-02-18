#!/usr/bin/env -S rdmd -g -I.. -O
module day23.solution;

import std.stdio;
import common.io;

import std.algorithm;
import std.array;
import std.conv;
import std.concurrency;
import std.format;
import std.math;
import std.range;
import std.stdio;
import std.typecons;

import common.io;
import common.vec;
import common.bfs;
import common.astar;
import common.util;
import common.coordrange;
import common.grid;

enum int[char] podCosts = [
	'A': 1, 'B': 10, 'C': 100, 'D': 1000
];

enum int[char]roomx = [
	'A': 3, 'B': 5, 'C': 7, 'D': 9
];

struct Move {
	int cost;
	int from;
	int to;
}

struct Location {
	int id;
	Point pos;
	bool isHallway;
	bool isForbidden;
	char type = '.';
	int[] adjacent;
	int[char] distanceHome;
	int nextInRoom = -1;
}

alias Map = Location[];

Map readMap(Grid!char grid) {
	
	Location[Point] locationByPos;
	int roomHeight = to!int(grid.size.y) - 3;
	int hallwayWidth = to!int(grid.size.x) - 2;

	// writeln(grid.format(""));
	foreach(pos; PointRange(grid.size)) {
		char c = grid.get(pos);
		if (".ABCD".canFind(c)) {
			Location loc;
			loc.pos = pos;

			// start with distance home through the hallway
			foreach(char type, int xx; roomx) {
				loc.distanceHome[type] = abs(pos.x - xx) + 1;
			}
			if (pos.y == 1) {
				loc.isHallway = true;
				loc.id = pos.x - 1;
			}
			else if (pos.y > 1) {
				int roomIndex = (pos.x - 3) / 2; // where 0 is A, 1 is B, etc.
				int posInRoom = pos.y - 2;
				loc.type = "ABCD"[(pos.x - 3) / 2];
				
				// backward-compatible way to assign ids to locations... can be simplified after transition done.
				loc.id = hallwayWidth + posInRoom + roomIndex * roomHeight;

				if (posInRoom + 1 < roomHeight) {
					loc.nextInRoom = loc.id + 1;
				}

				foreach(char type, int xx; roomx) {
					// if we're already home, then distance home is zero.
					if (type == loc.type) { loc.distanceHome[type] = 0; }
					// else add the vertical distance through the room we're in.
					else { loc.distanceHome[type] += posInRoom + 1; }
				}
			}
			locationByPos[pos] = loc;
		}
	}

	// find adjacents, and convert to map by id.
	Map result;
	result.length = locationByPos.length;
	foreach(pos, loc; locationByPos) {
		foreach(delta; [Point(1, 0), Point(0, 1), Point(-1, 0), Point(0, -1)]) {
			Point np = pos + delta;
			if (np in locationByPos) {
				loc.adjacent ~= locationByPos[np].id;
			}
		}
		sort(loc.adjacent);
		if (loc.adjacent.length >= 3) {
			loc.isForbidden = true;
		}
		result[loc.id] = loc;
	}

	// foreach(loc; result) {
	// 	writefln("%s: %s %s %s", loc.id, loc.pos, loc.nextInRoom, loc.adjacent);
	// }

	return result;
}

struct Data {
	Map map;
	char[] initialState;
	char[] goalState;
}

// calculate cost of putting everyting in its right state...
int heuristic(State)(State state, ref Map map) {
	int result = 0;
	foreach(ulong pos, char pod; state) {
		if (pod == '.') continue;
		result += map[pos].distanceHome[pod] * podCosts[pod];
	}
	return result;
}

Data parse(string[] lines) {
	Point size = Point(to!int(lines[0].length), to!int(lines.length));
	
	Grid!char grid = new Grid!char(size.x, size.y);
	foreach(pos; PointRange(grid.size)) {
		string line = lines[pos.y];
		char ch = pos.x < line.length ? line[pos.x] : ' ';
		grid.set(pos, ch);
	}

	Map map = readMap(grid);

	char[] pods;
	char[] goalPods;
	foreach(id, loc; map) {
		if (loc.isHallway) {
			pods ~= '.';
			goalPods ~= '.';
		}
		else {
			pods ~= grid.get(loc.pos);
			goalPods ~= loc.type;
		}
	}

	return Data(map, pods, goalPods);
}

Tuple!(Move, State)[] validMoves(State)(State state, ref Map map) {
	Tuple!(Move, State)[] result;
	// create a position map
	
	// writeln("Moves from state   : ", state);
	foreach (int source, char pod; state) {
		if (pod == '.') continue;
		
		int[] adjFunc(int i) {
			return map[i].adjacent.filter!(j => state[j] == '.').array;
		}

		// calculate cost for all Edges where pod p can go...
		outer: foreach(int dest, int cost; BfsVisitor!int(source, &adjFunc)) {
			State newState = state;
			newState[source] = '.';
			newState[dest] = pod;

			// writefln("Considering: %s from %s to %s: %s", pod, source, dest, newState);
			bool podInHallway = map[source].isHallway;
			bool destInHallway = map[dest].isHallway;
			// never stop on t-section
			if (map[dest].isForbidden) continue;

			// don't move within hallway or within a room
			if (map[source].type == map[dest].type) continue;
			
			// don't move to room unless it's the destination
			if (!destInHallway && map[dest].type != pod) continue;

			// When moving into a room, close rank: 
			// Check that the next spots in the same room aren't empty or the wrong type
			for (int furtherInRoom = map[dest].nextInRoom; furtherInRoom > 0; furtherInRoom = map[furtherInRoom].nextInRoom) {
				if (state[furtherInRoom] != pod) continue outer;
			}

			// writefln("Pod %s from %02s to %02s: %s, cost: %s", pod, source, dest, newState, cost * podCosts[pod]);
			result ~= tuple(Move(cost * podCosts[pod], source, dest), newState);
		}
	}

	// readln();
	return result;
}

alias State8 = char[19];
alias Edge8 = Tuple!(Move, State8);

auto solve1(string[] lines) {
	auto data = parse(lines);

	State8 state;
	state[0..19] = data.initialState;
	State8 goal;
	goal[0..19] = data.goalState;

	auto astarResult = astar!(State8, Move)(
		state, 
		s => s == goal, 
		s => s.validMoves!State8(data.map), 
		(Edge8 m) => m[0].cost,
		s => s.heuristic(data.map)
	);
	auto current = goal;
	assert(current in astarResult.prev);
	return astarResult.prev[goal].cost;
}

alias State16 = char[27];
alias Edge16 = Tuple!(Move, State16);

auto solve2(string[] lines) {
	auto data = parse(lines);

	State16 state;
	state[0..27] = data.initialState;
	State16 goal;
	goal[0..27] = data.goalState;

	auto astarResult = astar!(State16, Move)(
		state, 
		s => s == goal, 
		s => s.validMoves!State16(data.map), 
		(Edge16 m) => m[0].cost,
		s => s.heuristic(data.map)
	);
	auto current = goal;
	assert(current in astarResult.prev);
	return astarResult.prev[goal].cost;
}

void main(string[] args) {
	assert(args.length == 2, "Argument expected: input file");
	
	string[] lines = readLines(args[1]);
	string[] lines2 = lines[0..3] ~ ["  #D#C#B#A#", "  #D#B#A#C#" ] ~ lines[3..$];

	writeln ([
		solve1(lines),
		solve2(lines2)
	]);
}
