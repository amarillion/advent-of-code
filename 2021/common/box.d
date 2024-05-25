module common.box;

import common.vec;
import common.coordrange;
import std.algorithm;
import std.array;

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

	/** 
	* Measure is the mathimatical term for the volume of a box, the area of a rectangle, or the length of a line segment.
	*/
	@property
	T measure() const {
		T result = 1;
		foreach(i; 0..N) {
			result *= size.val[i];
		}
		return result;
	}

	static if (N == 2) {
		alias area = measure;
	} 
	static if (N == 3) {
		alias volume = measure;
	}
	static if (N == 4) {
		alias hypervolume = measure;
	}
}

/** 
* Measure is the mathimatical term for the volume of a box, the area of a rectangle, or the length of a line segment.
*/
@property
T measure(int N, T)(const ref Box!(N, T) a) {
	T result = 1;
	foreach(i; 0..N) {
		result *= a.size.val[i];
	}
	return result;
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

/** 
 * Slice a box in two according to an axis-aligned plane.
 * pos and dim define a plane that potentially splits the box into two.
 * Params:
 *   a = box to split
 *   pos = axis position to split at
 *   dim = dimension to split along, dim must be between 0 and N
 * Returns: 
 *   An array of one box, if there was no intersection, or two disjoint boxes that together make up the original box.
 */
Box!(N, T)[] bisect(int N, T)(Box!(N, T) a, T pos, int dim) {
	alias mybox = Box!(N, T);
	alias myvec = vec!(N, T);
	myvec p1 = a.pos;
	myvec p2 = a.pos + a.size;

	// doesn't bisect, return unchanged.
	if (pos <= p1.val[dim] || pos >= p2.val[dim]) {
		return [ a ];
	}

	myvec s1 = a.size;
	s1.val[dim] = pos - p1.val[dim];
	myvec s2 = a.size;
	s2.val[dim] = p2.val[dim] - pos;
	
	myvec p15 = p1;
	p15.val[dim] = pos;

	// invariant: all sizes are positive
	assert(all!"a > 0"(s1.val[]));
	assert(all!"a > 0"(s2.val[]));
	
	return [
		mybox(p1, s1),
		mybox(p15, s2)
	];
}

unittest {
	// unit test for bisect:
	auto a = Rect!int(Point(0, 0), Point(10, 10));
	auto vert = bisect(a, 5, 0);
	assert(vert.length == 2);
	assert(vert[0] == Rect!int(Point(0, 0), Point(5, 10)));
	assert(vert[1] == Rect!int(Point(5, 0), Point(5, 10)));
	auto horiz = bisect(a, 5, 1);
	assert(horiz.length == 2);
	assert(horiz[0] == Rect!int(Point(0, 0), Point(10, 5)));
	assert(horiz[1] == Rect!int(Point(0, 5), Point(10, 5)));
	auto noSplit = bisect(a, 20, 1);
	assert(noSplit.length == 1);
	assert(noSplit[0] == a);
}

// splits a & b in three lists: parts of a, overlapping, and parts of b.
// returns variable number of boxes. For 2-dimensions, up to 9. For 3-dimensions, up to 27
Box!(N, T)[][] intersections(int N, T)(Box!(N, T) a, Box!(N, T) b) {
	alias mybox = Box!(N, T);
	alias myvec = vec!(N, T);
	
	mybox[] aSplits = [ a ];
	mybox[] bSplits = [ b ];

	myvec a1 = a.pos;
	myvec a2 = a.pos + a.size;
	myvec b1 = b.pos;
	myvec b2 = b.pos + b.size;

	for (int dim = 0; dim < N; ++dim) {
		aSplits = aSplits.map!(q => q.overlaps(b) ? q.bisect(b1.val[dim], dim).array : [ q ]).join.array;
		aSplits = aSplits.map!(q => q.overlaps(b) ? q.bisect(b2.val[dim], dim).array : [ q ]).join.array;
		bSplits = bSplits.map!(q => q.overlaps(a) ? q.bisect(a1.val[dim], dim).array : [ q ]).join.array;
		bSplits = bSplits.map!(q => q.overlaps(a) ? q.bisect(a2.val[dim], dim).array : [ q ]).join.array;
	}

	// determine overlapping
	sort(aSplits);
	sort(bSplits);
	mybox[] overlapping = aSplits.setIntersection(bSplits).array;
	aSplits = aSplits.setDifference(overlapping).array;
	bSplits = bSplits.setDifference(overlapping).array;
	return [
		aSplits,
		overlapping,
		bSplits
	];
}

unittest {
	// unittest for intersects:
	// TODO
}
