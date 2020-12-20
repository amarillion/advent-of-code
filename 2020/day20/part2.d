#!/usr/bin/env rdmd

import std.stdio;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.format : formattedRead;

import helix.vec;

struct CoordRange(T) {
	
	T pos;
	T start;
	T endInclusive;

	this(T start, T endInclusive) {
		pos = start;
		this.start = start;
		this.endInclusive = endInclusive;
	}

	T front() {
		return pos;
	}

	void popFront() {
		pos.val[0]++;
		foreach (i; 0 .. pos.val.length - 1) {
			if (pos.val[i] > endInclusive.val[i]) {
				pos.val[i] = start.val[i];
				pos.val[i+1]++;		
			}
			else {
				break;
			}
		}
	}

	bool empty() const {
		return pos.val[$-1] > endInclusive.val[$-1]; 
	}

}

class SparseInfiniteGrid(T, U) {

	U[T] data;
	T min;
	T max;

	U get(T p) {
		if (p in data) {
			return data[p];
		}
		else {
			return U.init;
		}
	}

	void set(T p, U val) {
		// we'll save a bit of space by not storing default values
		if (val != U.init) {	
			min.lowestCorner(p);
			max.highestCorner(p);
			data[p] = val;
		}
	}

	override string toString() {
		char[] result;
		int i = 0;
		const T size = (max - min) + 1;
		const int lineSize = size.x;
		const int blockSize = size.x * size.y;
		foreach (base; CoordRange!T(min, max)) {
			if (i % lineSize == 0) {
				result ~= "\n";
			}
			static if (base.val.length > 2) {
				if (i % blockSize == 0) {
					result ~= format("%s\n", base);
				}
			}
			result ~= format("%s %s ", base, get(base));
			i++;
		}
		result ~= '\n';
		return result.idup;
	}

	void transform(U delegate(T) transformCell) {
		auto newData = new SparseInfiniteGrid!(T, U)();
		foreach (p; CoordRange!T(min - 1, max + 1)) {
			newData.set(p, transformCell(p));
		}
		data = newData.data;
		min = newData.min;
		max = newData.max;		
	}
}

class Grid {
	char[] data;
	ulong width, height;
	
	this(ulong width, ulong height) {
		this.width = width;
		this.height = height;
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

struct Tile {
	
	string[] lines;
	ulong width, height;
	string[4] sides;
	int idx;

	this(int idx, string[] lines) {
		this.idx = idx;
		width = lines[0].length;
		height = lines.length;	
		this.lines = lines;
		sides[Side.TOP] = lines[0];
		sides[Side.BOTTOM] = lines[$-1];
		sides[Side.LEFT] = lines.map!(l => l[0]).array;
		sides[Side.RIGHT] = lines.map!(l => l[$-1]).array;
	}

	bool hasSide(string side) {
		foreach (s; sides) {
			if (s == side) return true;
			if (s == reverse(side.dup).idup) return true;
		}
		return false;
	}

	bool matchTile(Side s, string needle) {
		// modifies tile in place to match rotation - TODO refactor
		string[4] rev;
		foreach (i, x; sides) {
			rev[i] = reverse(x.dup).idup;
		}
		foreach (i; 0..4) {
			if (sides[(s + i) % 4] == needle) {
				auto result = sides[i..$] ~ sides[0..i];
				writefln("Rotating %s times: %s => %s", i, sides, result);
				sides = result;
				return true;
			}
			
			if (rev[(s + i) % 4] == needle) {
				auto result = rev[i..$] ~ rev[0..i];
				writefln("Rotating %s times and reverse: %s => %s", i, sides, result);
				sides = result;
				return true;
			}
			
		}
		return false;
	}

	string toString() {
		return format("%s: sides %s", idx, sides);
	}
}

Tile[int] tiles;
Fingerprint[][string] fprints;
int[string] fprintFreq;

int findTopLeftCornerPiece() {

	foreach(idx, tile; tiles) {	
		// count matches on top-left of this tile

		int count = 0;
		count += fprints[tile.sides[Side.TOP]].length;
		count += fprints[tile.sides[Side.LEFT]].length;
		
		if ((fprintFreq[tile.sides[Side.LEFT]] == 1) && (fprintFreq[tile.sides[Side.TOP]] == 1)) {
			return idx;
		}
	}
	return 0; // not found

}

void main()
{
	File file = File("test", "rt");
	while (!file.eof) {
		string[] paragraph = readParagraph(file);
		int idx;
		if (paragraph.length == 0) continue;
		paragraph[0].formattedRead("Tile %d:", &idx);
		assert(idx > 0);
		Tile tile = Tile(idx, paragraph[1..$]);
		tiles[idx] = tile;

		for (auto s = Side.min; s <= Side.max; ++s) {
			fprints[tile.sides[s]] ~= Fingerprint(idx, s, false);
			fprints[tile.sides[s].dup.reverse().idup] ~= Fingerprint(idx, s, true);

			fprintFreq[tile.sides[s]]++;
			fprintFreq[tile.sides[s].dup.reverse().idup]++;
		}

	}

	writeln(fprintFreq);

	long result = 1;
	int topLeftCornerIdx = findTopLeftCornerPiece();

	auto tilemap = new SparseInfiniteGrid!(Point, int)();
	
	Point pos = Point(0, 0);
	tilemap.set(pos, topLeftCornerIdx);

	Tile[] remain = tiles.values;
	remain = remain.filter!(t => t.idx != topLeftCornerIdx).array;

	for (int y = 0;; y++) {
		for (int x = 0;; x++) {
			pos = Point(x, y); 
			if (tilemap.get(pos) > 0) { continue; }
			
			int leftSide = tilemap.get(Point(x-1, y));
			int topSide = tilemap.get(Point(x, y-1));
			
			writefln("Finding match at pos %s bordering %s %s", pos, leftSide, topSide);
			
			auto f = remain;

			writeln("Before", f.length);
			if (leftSide != 0) {
				f = f.filter!(tile => tile.matchTile(Side.LEFT, tiles[leftSide].sides[Side.RIGHT])).array;
				writeln("After filtering left side: ", f.length, "\n", f);
			}
			else {
				// f = f.filter!(tile => fprintFreq[tile.sides[Side.LEFT]] == 1).array;
				// writeln("Is edge piece on left: ", f.length, "\n", f.map!(t => t.idx).array);
			}
			

			if (topSide != 0) {
				f = f.filter!(tile => tile.matchTile(Side.TOP, tiles[topSide].sides[Side.BOTTOM])).array;
				writeln("After filtering top side: ", f.length, "\n", f);
			}
			else {
				// f = f.filter!(tile => fprintFreq[tile.sides[Side.TOP]] == 1).array;
				// writeln("Is edge piece on top: ", f.length, "\n", f);
			}

			readln();

			if (f.empty) {
				break;
			}

			assert(f.length == 1);

			tilemap.set(pos, f[0].idx);
			remain = remain.filter!(t => t != f[0]).array;

			writefln("Remaining tiles: %s", remain);
		}
		
		if (remain.empty) {
			break;
		}
	}

	writeln(tilemap);
}
