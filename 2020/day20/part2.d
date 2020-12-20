#!/usr/bin/env rdmd

import std.stdio;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.format : formattedRead;
import std.range;

import helix.vec;
import helix.io;
import helix.grid;

enum Side { TOP, RIGHT, BOTTOM, LEFT };

Point transformPoint(Point p, int rotation, bool flip, int pivot) {
	// transform p according to rotation/reverse...
	Point o;
	switch(rotation) {
		case 0: o = p; break;
		case 1: o = Point(p.y, pivot-p.x); break;
		case 2: o = Point(pivot-p.x, pivot-p.y); break;
		case 3: o = Point(pivot-p.y, p.x); break;
		default: assert(false);
	}
	if (flip) {
		o = Point(pivot-o.x, o.y);
	}
	return o;
}

struct Tile {
	Grid!char grid;	
	int idx;
	int rotation = 0;
	bool flip = false;

	this(int idx, string[] lines) {
		this.idx = idx;
		int width = cast(int)lines[0].length;
		int height = cast(int)lines.length;
		grid = new Grid!char(width, height);
		foreach (pos; PointRange(Point(width, height) - 1)) {
			grid.set(pos, lines[pos.y][pos.x]);
		}
	}

	string sides(Side s) const {
		const int height = cast(int)grid.height;
		const int width = cast(int)grid.width;
		final switch (s) {
			case Side.TOP:
				return Walk!Point(Point(0, 0), Point(1, 0), 10).map!(i => get(i)).array.idup;
			case Side.BOTTOM:
				return Walk!Point(Point(0, height-1), Point(1, 0), 10).map!(i => get(i)).array.idup;
			case Side.LEFT:
				return Walk!Point(Point(0, 0), Point(0, 1), 10).map!(i => get(i)).array.idup;
			case Side.RIGHT:
				return Walk!Point(Point(width-1, 0), Point(0, 1), 10).map!(i => get(i)).array.idup;
		}
	}

	char get(Point p) const {
		Point o = transformPoint(p, rotation, flip, 9);

		// writefln("%s %s; %s => %s", rotation, flip, p, o);
		return grid.get(o);
	}

	string echo() {
		// TODO: causes segfault??? // Maybe when called on Tile.init ???
		char[] result = format("Tile %s: %s %s\n", idx, rotation, flip).dup;
		int i = 0;
		
		const Point size = Point(cast(int)grid.width, cast(int)grid.height);

		const int lineSize = size.x;
		bool firstLine = true;
		foreach (base; PointRange(Point(0), size - 1)) {
			if (i % lineSize == 0 && !firstLine) {
				result ~= "\n";
			}
			result ~= get(base);
			i++;			
			firstLine = false;
		}
		return result.idup;
	}

	string toString() {
		return format(flip ? "%s r%s flip" : "%s r%s", idx, rotation);
	}

}

Tile[] tileVariants;
int[string] fprintFreq;

Tile findTopLeftCornerPiece() {

	foreach(tile; tileVariants) {	
		// count matches on top-left of this tile		
		if ((fprintFreq[tile.sides(Side.LEFT)] == 1) && (fprintFreq[tile.sides(Side.TOP)] == 1)) {
			return tile;
		}
	}
	assert(false);
}

void copyTile(Point pos, SparseInfiniteGrid!(Point, Tile) tilemap, Grid!(char) grid) {
	Tile tile = tilemap.get(pos);
	Point dest = pos * 8;
	foreach (base; PointRange(Point(7))) {
		grid.set(dest + base, tile.get(base + 1));
	}
}

void main()
{
	File file = File("input", "rt");

	while (!file.eof) {
		string[] paragraph = readParagraph(file);
		int idx;
		if (paragraph.length == 0) continue;
		paragraph[0].formattedRead("Tile %d:", &idx);
		assert(idx > 0);
		Tile tile = Tile(idx, paragraph[1..$]);

		foreach (i; 0..4) {
			Tile tile2 = tile;
			tile2.flip = false;
			tile2.rotation = i;
			tileVariants ~= tile2;
			Tile tile3 = tile;
			tile3.rotation = i;
			tile3.flip = true;
			tileVariants ~= tile3;
		}
	}

	foreach (const ref tile; tileVariants) {
		fprintFreq[tile.sides(Side.TOP)]++;
	}

	long result = 1;
	// TODO: integrate solution for part 1...
	
	Tile topLeftCorner = findTopLeftCornerPiece();
	writefln("Identified corner piece %s", topLeftCorner.idx);

	auto tilemap = new SparseInfiniteGrid!(Point, Tile)();
	
	Point pos = Point(0, 0);
	tilemap.set(pos, topLeftCorner);

	Tile[] remain = tileVariants;
	remain = remain.filter!(t => t.idx != topLeftCorner.idx).array;

	// infinite for loops, size of map is unknown
	for (int y = 0;; y++) {
		for (int x = 0;; x++) {
			pos = Point(x, y); 
			if (tilemap.get(pos).idx > 0) { continue; }
			
			Tile leftSide = tilemap.get(Point(x-1, y));
			Tile topSide = tilemap.get(Point(x, y-1));
			
			// writefln("Finding match at pos %s bordering %s on the left and %s on the top", pos, leftSide, topSide);			
			auto f = remain;
			if (leftSide.idx != 0) {
				f = f.filter!(tile => tile.sides(Side.LEFT) == leftSide.sides(Side.RIGHT)).array;
			}
			if (topSide.idx != 0) {
				f = f.filter!(tile => tile.sides(Side.TOP) ==  topSide.sides(Side.BOTTOM)).array;
			}

			if (f.empty) {
				break; // no piece can be placed here, continue on next line
			}

			assert(f.length == 1);

			tilemap.set(pos, f[0]);
			remain = remain.filter!(t => t.idx != f[0].idx).array;
		}
		
		// if there are no more pieces remaining, we have filled the map
		if (remain.empty) {
			break;
		}
	}

	auto grid = new Grid!(char)((tilemap.max.x + 1) * 8, (tilemap.max.y + 1) * 8, '`');
	foreach (p; PointRange(tilemap.max)) {
		copyTile(p, tilemap, grid);
	}

	// writeln(grid.format("", "\n"));
	// writeln(tilemap);

	// now let's find some monsters...
	Point[] monster = [
			Point( 0,0), 
				Point( 1,1),
			
			
				Point( 4,1),
			Point( 5,0),
			Point( 6,0),
				Point( 7,1),
			
			
				Point(10,1),
			Point(11,0),
			Point(12,0),
				Point(13,1),
				
				
				Point(16,1),
			Point(17,0),
		Point(18,0), Point(18,-1),
			Point(19,0)
	];

	foreach(base; PointRange(Point(cast(int)grid.width - 1, cast(int)grid.height - 1))) {
		foreach(flip; [ false, true ]) {
			foreach(rotation; 0..4) {
				bool match = true;
				foreach(i, mpoint; monster) {
					Point o = base + transformPoint(mpoint, rotation, flip, 0);
					if (!grid.inRange(o)) {
						match = false;
						break;
					}
					if(grid.get(o) != '#' && grid.get(o) != 'O') {
						match = false;
						break;
					}
				}
				if (match) {
					// writefln("Monster found at %s", base);
					foreach(mpoint; monster) {
						Point o = base + transformPoint(mpoint, rotation, flip, 0);
						grid.set(o, 'O');
					}
				}
			}
		}
	}

	writeln(grid.format("", "\n"));

	long roughness = 0;
	foreach(base; PointRange(Point(cast(int)grid.width - 1, cast(int)grid.height - 1))) {
		if (grid.get(base) == '#') roughness++;
	}
	writefln("Roughness: %s", roughness);
}
