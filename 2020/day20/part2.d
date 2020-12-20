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

Grid!char readGrid(string[] lines) {
	int width = cast(int)lines[0].length;
	int height = cast(int)lines.length;
	auto grid = new Grid!char(width, height);
	foreach (pos; PointRange(grid.size)) {
		grid.set(pos, lines[pos.y][pos.x]);
	}
	return grid;
}

struct Tile {

	Grid!char grid;
	int idx;
	int rotation = 0;
	bool flip = false;

	Tile variant(int rotValue, bool flipValue) {
		return Tile(grid, idx, rotValue, flipValue); 
	}

	string sides(Side s) const {
		const int height = cast(int)grid.height;
		const int width = cast(int)grid.width;
		const Point RIGHT = Point(1,0);
		const Point DOWN = Point(0, 1);
		final switch (s) {
			case Side.TOP:
				return Walk!Point(Point(0, 0), RIGHT, 10).map!(i => get(i)).array.idup;
			case Side.BOTTOM:
				return Walk!Point(Point(0, height-1), RIGHT, 10).map!(i => get(i)).array.idup;
			case Side.LEFT:
				return Walk!Point(Point(0, 0), DOWN, 10).map!(i => get(i)).array.idup;
			case Side.RIGHT:
				return Walk!Point(Point(width-1, 0), DOWN, 10).map!(i => get(i)).array.idup;
		}
	}

	char get(Point p) const {
		Point o = transformPoint(p, rotation, flip, 9);
		return grid.get(o);
	}

	string toString() {
		return format(flip ? "%s r%s flip" : "%s r%s", idx, rotation);
	}

}

Tile[] tileVariants;
int[string] fprintFreq;

// see if this piece connects on the top-left.
// if we check this for all tile rotations, eventually we'll end up with all corner pieces.
bool isCornerPiece(Tile tile) {
	return (
		!tile.flip && // two possible combinations will fit, limit ourselves to just one
		(fprintFreq[tile.sides(Side.LEFT)] == 1) && 
		(fprintFreq[tile.sides(Side.TOP)] == 1)
	);
}

void copyTile(Point pos, SparseInfiniteGrid!(Point, Tile) tilemap, Grid!(char) grid) {
	Tile tile = tilemap.get(pos);
	Point dest = pos * 8;
	foreach (base; PointRange(Point(8))) {
		grid.set(dest + base, tile.get(base + 1));
	}
}

Point topOf(Point p) { return Point(p.x, p.y - 1); }
Point leftOf(Point p) { return Point(p.x - 1, p.y); }

void main()
{
	File file = File("input", "rt");

	while (!file.eof) {
		string[] paragraph = readParagraph(file);
		int idx;
		if (paragraph.length == 0) continue;
		paragraph[0].formattedRead("Tile %d:", &idx);
		assert(idx > 0);
		Tile tile = Tile(readGrid(paragraph[1..$]), idx);

		foreach (i; 0..4) {
			tileVariants ~= tile.variant(i, false);
			tileVariants ~= tile.variant(i, true);
		}
	}

	foreach (const ref tile; tileVariants) {
		fprintFreq[tile.sides(Side.TOP)]++;
	}

	
	Tile[] cornerPieces = tileVariants.filter!isCornerPiece().array;
	
	long part1result = reduce!((acc, cur) => acc * cur.idx)(1L, cornerPieces);
	writefln("Part 1: %s", part1result);
	
	auto tilemap = new SparseInfiniteGrid!(Point, Tile)();
	
	Tile[] remain = tileVariants;
	
	// one of the corner pieces is our seed.
	Tile foundPiece = cornerPieces[0];
	
	Tile[] findTilesThatFit(Point pos) {
		Tile leftSide = tilemap.get(leftOf(pos));
		Tile topSide = tilemap.get(topOf(pos));
		
		// writefln("Finding match at pos %s bordering %s on the left and %s on the top", pos, leftSide, topSide);		
		auto f = remain;
		if (leftSide != Tile.init) {
			f = f.filter!(tile => tile.sides(Side.LEFT) == leftSide.sides(Side.RIGHT)).array;
		}
		if (topSide != Tile.init) {
			f = f.filter!(tile => tile.sides(Side.TOP) ==  topSide.sides(Side.BOTTOM)).array;
		}

		return f;		
	}

	Point pos = Point(0, 0);
	while (true) {
		tilemap.set(pos, foundPiece);

		// filter out all related variants
		remain = remain.filter!(t => t.idx != foundPiece.idx).array;
		if (remain.empty) {
			break;
		}

		pos.x = pos.x + 1; //TODO: increment operator not allowed yet...

		Tile[] f = findTilesThatFit(pos);
		if (f.empty) {
			// no piece can be placed here, continue on next line
			pos.y = pos.y + 1;
			pos.x = 0;
			f = findTilesThatFit(pos);
		}

		// the puzzle is designed so that always only one piece fits here.
		assert(f.length == 1);
		foundPiece = f[0];
	}

	auto grid = new Grid!(char)((tilemap.max + 1) * 8, '`');
	foreach (p; PointRange(tilemap.max + 1)) {
		copyTile(p, tilemap, grid);
	}

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

	foreach(base; PointRange(grid.size)) {
		foreach(flip; [ false, true ]) {
			foreach(rotation; 0..4) {
				bool match = true;
				foreach(i, mpoint; monster) {
					Point o = base + transformPoint(mpoint, rotation, flip, 0);
					if (!grid.inRange(o)) {
						match = false;
						break;
					}
					if(grid.get(o) == '.') {
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
	foreach(base; PointRange(grid.size)) {
		if (grid.get(base) == '#') roughness++;
	}
	writefln("Part 2: %s", roughness);
}
