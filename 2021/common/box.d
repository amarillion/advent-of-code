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
	bool contains(vec!(N, T) p) {
		foreach(i; 0..N) {
			if (p.val[i] < pos.val[i] || p.val[i] >= pos.val[i] + size.val[i]) { return false; }
		}
		return true;
	}
}

alias Rect(T) = Box!(2, T);
alias Cuboid(T) = Box!(3, T);
alias Hyperrect(T) = Box!(4, T);

unittest {	
	auto unit = Rect!int(Point(1,1), Point(1, 1));
	assert (unit.inside(Point(0, 1)) == false);
	assert (unit.inside(Point(1, 1)) == true);
	assert (unit.inside(Point(2, 1)) == false);
}