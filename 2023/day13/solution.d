#!/usr/bin/env -S rdmd -I..
module day13.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;

import common.io;
import common.grid;

alias Data = Grid!(2, char)[];

Data parse(string fname) {
	auto reader = new FileReader(fname);
	Data result;
	while(!reader.eof) {
		result ~= readGrid(reader);
	}
	return result;
}

bool checkVSymmetry(Grid!(2, char) grid, int center) {
	for (int x = 0; x < grid.width; ++x) {
		int x1 = center - x;
		int x2 = center + x + 1;
		if (x1 < 0 || x2 >= grid.width) return true;
		if (grid.col[x1].array != grid.col[x2].array) return false;
	}
	return true;
}

bool checkHSymmetry(Grid!(2, char) grid, int center) {
	for (int y = 0; y < grid.height; ++y) {
		int y1 = center - y;
		int y2 = center + y + 1;
		if (y1 < 0 || y2 >= grid.height) return true;
		if (grid.row[y1].array != grid.row[y2].array) return false;
	}
	return true;
}

auto solve1(Data data) {
	long result = 0;
	foreach(grid; data) {
		// check for horizontal symmetry. Find consecutive matches
		int vsymmetry = -1;
		for (int x = 0; x < grid.size.x - 1; ++x) {
			if (grid.col[x].array == grid.col[x+1].array) {
				if (checkVSymmetry(grid, x)) {
					vsymmetry = x + 1;
					break;
				}
			}
		}

		int hsymmetry = -1;
		for (int y = 0; y < grid.size.y - 1; ++y) {
			if (grid.row[y].array == grid.row[y+1].array) {
				if (checkHSymmetry(grid, y)) {
					hsymmetry = y + 1;
					break;
				}
			}
		}

		writeln(grid.size);
		writeln(grid.format(""));

		if (hsymmetry > 0) result += hsymmetry * 100;
		if (vsymmetry > 0) result += vsymmetry;
		writefln("HSymmetry: %s; VSymmetry: %s; sum: %s", hsymmetry, vsymmetry, result);
	}
	return result;
}

void main() {
	auto testData = parse("test-input");
	assert(solve1(testData) == 405, "Solution incorrect");

	auto data = parse("input");
	auto result = solve1(data);
	// assert(result == 1);
	writeln(result);
}
