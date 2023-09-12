#!/usr/bin/env -S rdmd -I..

import common.io;
import common.grid;
import common.vec;
import std.stdio;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.format : formattedRead;
import std.exception;

alias MyGrid = SparseInfiniteGrid!(Point, bool);

string[] parse(string s) {
	char[] base = [];
	string[] result = [];

	foreach(ch; s) {
		base ~= ch;
		if (!(ch == 's' || ch == 'n')) {
			result ~= base.idup;
			base = [];
		}
	}
	assert(base.empty);
	return result;
}

unittest {
	assert (parse("nwwswee") == ["nw", "w", "sw", "e", "e"]);
	assert (parse("esenee") == ["e", "se", "ne", "e"]);
}

Point[] toSteps(string[] path) {
	Point[string] STEPS = [
		"se": Point(1, 1),
		"nw": Point(-1, -1),
		
		"sw": Point(0, 1),
		"ne": Point(0, -1),

		"e": Point(1, 0),
		"w": Point(-1, 0),
	];
	return path.map!(s => STEPS[s]).array;
}

unittest {
	assert (toSteps(["e", "w"]) == [ Point(1, 0), Point(-1, 0)]);
}

Point walkLine(Point[] path) {
	Point pos = Point(0);
	foreach(step; path) {
		pos = pos + step;
	}
	return pos;
}

unittest {
	Point[] p1 = toSteps(["nw", "w", "sw", "e", "e"]);
	Point pos = walkLine(p1);
	assert(pos == Point(0, 0));

	Point[] p2 = toSteps(["e", "se", "w"]);
	pos = walkLine(p2);
	assert(pos == Point(1, 1));
}

void main() {

	MyGrid grid = new MyGrid();
	foreach(line; readLines("input")) {
		Point[] path = toSteps(parse(line));
		Point pos = walkLine(path);
		grid.set(pos, !grid.get(pos));
	}

	writeln("Part 1 result:");
	writeln(grid.data.length);

	Point[] adjacent = [
		Point(1, 1),
		Point(-1, -1),
		Point(0, 1),
		Point(0, -1),
		Point(1, 0),
		Point(-1, 0),
	];

	bool updateCell(Point p) {
		int count = 0;
		// count adjacent
		foreach(delta; adjacent) {
			if (grid.get(p + delta)) {
				count++;
			}
		}
		bool val = grid.get(p);
		bool result = val;
		if (val && (count == 0 || count > 2)) {
			result = false;
		}
		if (!val && count == 2) {
			result = true;
		}
		return result;
	}

	foreach(day; 0..100) {	
		grid.transform(p => updateCell(p));
		writefln("Day %s: %s", day + 1, grid.data.length);
	}
}
