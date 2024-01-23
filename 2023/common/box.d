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
