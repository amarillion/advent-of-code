module day23.common;

import std.stdio;
import std.algorithm;
import std.format;
import std.conv;

import common.vec;
import common.grid;
import common.coordrange;


enum int[char] podCosts = [
	'A': 1, 'B': 10, 'C': 100, 'D': 1000
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
}

alias Map = Location[int];

Map readMap(Grid!char grid) {
	
	Location[Point] locationByPos;
	// writeln(grid.format(""));
	foreach(pos; PointRange(grid.size)) {
		char c = grid.get(pos);
		if (c == '.' || c == 'A' || c == 'B' || c == 'C' || c == 'D') {
			Location loc;
			loc.pos = pos;
			if (pos.y == 1) {
				loc.isHallway = true;
				loc.id = pos.x - 1;
			}
			else if (pos.y > 1) {
				// backward-compatible way to assign ids to locations... can be simplified after transition done.
				loc.id = to!int(grid.size.x) - 2 + pos.y - 2 + ((pos.x - 3) / 2) * (to!int(grid.size.y) - 3);
				switch (pos.x) {
					case 3: loc.type = 'A'; break;
					case 5: loc.type = 'B'; break;
					case 7: loc.type = 'C'; break;
					case 9: loc.type = 'D'; break;
					default: assert(false, format("Illegal location %s", pos));
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
	foreach(id, loc; map) {
		if (loc.isHallway) continue;

		pods ~= Pod(grid.get(loc.pos), id);
	}

	return Data(map, pods);
}