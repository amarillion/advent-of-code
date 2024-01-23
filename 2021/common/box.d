module common.box;

import common.vec;
import common.coordrange;

/** 
 * An n-dimensional box.
 */
struct Box(int N, T) {
	alias Coord = vec!(N, T);
	
	Coord pos;
	Coord size;

	this(Coord _pos, Coord _size) {
		this.pos = _pos;
		this.size = _size;
	}

	@property 
	CoordRange!(vec!(N, T)) coordrange() {
		return CoordRange!(vec!(N, T))(pos, pos + size);
	}

	/* Test if a point falls inside this box */
	bool contains(vec!(N, T) x) {
		foreach(i; 0..N) {
			if (x.val[i] < pos.val[i] || x.val[i] >= pos.val[i] + size.val[i]) { return false; }
		}
		return true;
	}

	bool overlaps(Box!(N,T) b) {
		Coord a1 = this.pos;
		Coord a2 = this.pos + this.size;
		Coord b1 = b.pos;
		Coord b2 = b.pos + b.size;

		foreach(i; 0..N) {
			if (a2.val[i] <= b1.val[i] || a1.val[i] >= b2.val[i]) return false;
		}
		return true;
	}

	// use "auto ref const" to allow Lval and Rval here.
	int opCmp()(auto ref const Box!(N, T) s) const {
		// sort first by pos, then by size
		if (pos == s.pos) {
			return size.opCmp(s.size);
		}
		return pos.opCmp(s.pos);
	}
}

alias Rect(T) = Box!(2, T);
alias Cuboid(T) = Box!(3, T);
alias Hyperrect(T) = Box!(4, T);

unittest {	
	auto unit = Rect!int(Point(1,1), Point(1, 1));
	assert (unit.contains(Point(0, 1)) == false);
	assert (unit.contains(Point(1, 1)) == true);
	assert (unit.contains(Point(2, 1)) == false);
}

unittest {
	Cuboid!int a = Cuboid!int(vec3i(0, 0, 0), vec3i(5, 3, 4));
	Cuboid!int b = Cuboid!int(vec3i(-2, 1, 2), vec3i(5, 4, 3));
	Cuboid!int c = Cuboid!int(vec3i(1,1,1), vec3i(1,1,1));

	vec3i p1 = vec3i(2, 1, 2);
	vec3i p2 = vec3i(8,0,0);

	assert(a.contains(p1));
	assert(b.contains(p1));
	assert(!a.contains(p2));
	assert(!b.contains(p2));
	
	assert(a.overlaps(a));
	assert(b.overlaps(b));
	assert(c.overlaps(c));

	assert(a.overlaps(b));
	assert(b.overlaps(a));
	assert(c.overlaps(a));
	assert(!c.overlaps(b));
}