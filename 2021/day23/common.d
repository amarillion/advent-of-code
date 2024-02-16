module day23.common;

import std.stdio;
import std.algorithm;
import std.format;
import std.conv;
import std.math;

import common.vec;
import common.grid;
import common.coordrange;


enum int[char] podCosts = [
	'A': 1, 'B': 10, 'C': 100, 'D': 1000
];

enum int[char]roomx = [
	'A': 3, 'B': 5, 'C': 7, 'D': 9
];

struct Pod {
	char type;
	int pos;

	this(char type, int pos) {
		assert(['A', 'B', 'C', 'D'].canFind(type), "Wrong type " ~ type);
		this.type = type;
		this.pos = pos;
	}
}

struct Move {
	int cost;
	Pod from;
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
}

alias Map = Location[int];

Map readMap(Grid!char grid) {
	
	Location[Point] locationByPos;
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
				loc.type = "ABCD"[(pos.x - 3) / 2];
				
				// backward-compatible way to assign ids to locations... can be simplified after transition done.
				loc.id = to!int(grid.size.x) - 2 + pos.y - 2 + (roomIndex) * (to!int(grid.size.y) - 3);

				foreach(char type, int xx; roomx) {
					// if we're already home, then distance home is zero.
					if (type == loc.type) { loc.distanceHome[type] = 0; }
					// else add the vertical distance through the room we're in.
					else { loc.distanceHome[type] += pos.y - 1; }
				}
			}
			locationByPos[pos] = loc;
		}
	}

	// find adjacents, and convert to map by id.
	Map result;
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

	// Location[] sortedLocations = result.values;
	// sort!"a.id < b.id"(sortedLocations);
	// foreach(loc; sortedLocations) {
	// 	writefln("%s: %s %s %s", loc.id, loc.pos, loc.isForbidden, loc.adjacent);
	// }

	return result;
}

struct Data {
	Map map;
	Pod[] initialPods;
	Pod[] goalPods;
}

// calculate cost of putting everyting in its right state...
int heuristic(State)(State state, ref Map map) {
	int result = 0;
	foreach(pod; state) {
		result += map[pod.pos].distanceHome[pod.type] * podCosts[pod.type];
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

	Pod[] pods;
	Pod[] goalPods;
	foreach(id, loc; map) {
		if (loc.isHallway) continue;

		// read original pod from map
		pods ~= Pod(grid.get(loc.pos), id);
		// also track target pod for this point
		goalPods ~= Pod(loc.type, id);
	}
	sort!"a.pos < b.pos"(goalPods);
	sort!"a.pos < b.pos"(pods);

	return Data(map, pods, goalPods);
}


void sortPods(State)(ref State state) {
	sort!((a, b) => a.pos < b.pos)(state[]);
}

bool isEndCondition(State)(State state, ref Map map) {
	foreach(Pod p; state) {
		if (map[p.pos].isHallway) return false;
		if (map[p.pos].type != p.type) return false;
	}
	return true;
}

bool targetRoomMismatch(State)(State state, int type, ref Map map) {
	foreach(p; state) {
		// ignore pods that are in the hallway
		if (map[p.pos].isHallway) continue;
		// for all the pods that are in the room of the target type
		if (map[p.pos].type != type) continue;

		// is that pod in the right room?
		if (p.type != type) return false;
	}
	return true;
}