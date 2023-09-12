#!/usr/bin/env rdmd

import std.stdio;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.format : formattedRead;

class Grid {
	string[] lines;
	ulong width, height;
	
	string top;
	string bottom;
	string left;
	string right;
	
	this(string[] lines) {
		width = lines[0].length;
		height = lines.length;	
		this.lines = lines;
		top = lines[0];
		bottom = lines[$-1];
		left = lines.map!(l => l[0]).array;
		right = lines.map!(l => l[$-1]).array;
	}
}

string[] readParagraph(File file) {
	string[] result = [];
	while (!file.eof()) {
		string line = chomp(file.readln()); 
		if (line.length == 0) {
			if (result.length == 0) continue;
			else break;
		}
		result = result ~ line;
	}
	return result;
}

string[] readLines(string fname) {
	File file = File(fname, "rt");
	string[] result = [];
	while (!file.eof()) {
		string line = chomp(file.readln()); 
		result = result ~ line;
	}
	// Remove empty line...
	if (result[$-1].length == 0) { result = result[0..$-1]; }
	return result;
}

enum Side { TOP, RIGHT, BOTTOM, LEFT };

struct Fingerprint {
	int tileIdx;
	Side side;
	bool reverse;
}

Grid[int] tiles;
Fingerprint[][string] fprints;

void main()
{
	
	File file = File("input", "rt");
	while (!file.eof) {
		string[] paragraph = readParagraph(file);
		int idx;
		if (paragraph.length == 0) continue;
		paragraph[0].formattedRead("Tile %d:", &idx);
		Grid tile = new Grid(paragraph[1..$]);
		tiles[idx] = tile;

		fprints[tile.top] ~= Fingerprint(idx, Side.TOP, false);
		fprints[tile.top.dup.reverse().idup] ~= Fingerprint(idx, Side.TOP, true);
		fprints[tile.right] ~= Fingerprint(idx, Side.RIGHT, false);
		fprints[tile.right.dup.reverse().idup] ~= Fingerprint(idx, Side.RIGHT, true);
		fprints[tile.bottom] ~= Fingerprint(idx, Side.BOTTOM, false);
		fprints[tile.bottom.dup.reverse().idup] ~= Fingerprint(idx, Side.BOTTOM, true);
		fprints[tile.left] ~= Fingerprint(idx, Side.LEFT, false);
		fprints[tile.left.dup.reverse().idup] ~= Fingerprint(idx, Side.LEFT, true);
	}

	long result = 1;
	foreach(idx, tile; tiles) {
		// count matches on this tile
		int count = 0;
		count += fprints[tile.top].length;
		count += fprints[tile.right].length;
		count += fprints[tile.bottom].length;
		count += fprints[tile.left].length;
		count += fprints[tile.top.dup.reverse().idup].length;
		count += fprints[tile.right.dup.reverse().idup].length;
		count += fprints[tile.bottom.dup.reverse().idup].length;
		count += fprints[tile.left.dup.reverse().idup].length;
		writeln(idx, " => ", count);

		if (count == 12) {
			result *= idx;
		}
	}
	writeln(result);
	// writeln(fprints);
}
