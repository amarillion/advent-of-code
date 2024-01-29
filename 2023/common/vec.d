module common.vec;

import std.conv;
import std.algorithm;

struct vec(int N, V) {
	V[N] val;
	
	// read access on const object
	@property V x() const { return val[0]; }
	// read access on non-const object
	@property ref V x() { return val[0]; }
	// write access
	@property void x(V v) { val[0] = v; }
	
	@property V y() const { return val[1]; }
	@property ref V y() { return val[1]; }
	@property void y(V v) { val[1] = v; }

	static if (N > 2) {
		@property V z() const { return val[2]; }
		@property ref V z() { return val[2]; }
		@property void z(V v) { val[2] = v; }
	}

	static if (N > 3) {
		@property V w() const { return val[3]; }
		@property ref V w() { return val[3]; }
		@property void w(V v) { val[3] = v; }
	}

	this(V x, V y, V z = 0, V w = 0) {
		static if (N == 4) {
			val = [x, y, z, w];
		}
		static if (N == 3) {
			val = [x, y, z];
		}
		static if (N == 2) {
			val = [x, y];
		}
	}

	this(V init) {
		foreach (i; 0..N) {
			val[i] = init;
		}
	}

	vec!(N, V) eachMin(const vec!(N, V) p) const {
		vec!(N, V) result;
		foreach (i; 0..N) {
			result.val[i] = min(p.val[i], val[i]);
		}
		return result;
	}

	vec!(N, V) eachMax(const vec!(N, V) p) const {
		vec!(N, V) result;
		foreach (i; 0..N) {
			result.val[i] = max(p.val[i], val[i]);
		}
		return result;
	}

	bool allLt(U)(const vec!(N, U) p) const {
		foreach (i; 0..N) {
			if (!(val[i] < p.val[i])) {
				return false;
			}
		}
		return true;
	}

	bool allGte(U)(const vec!(N, U) p) const {
		foreach (i; 0..N) {
			if (!(val[i] >= p.val[i])) {
				return false;
			}
		}
		return true;
	}

	/** 
	Applies std.math.sgn to each element in the vector. For example, vec3i(5, 0, -10) becomes vec3i(1, 0, -1)
	*/ 
	vec!(N, V) sgn() const {
		import std.math;
		vec!(N, V) result;
		foreach(i; 0..N) {
			result.val[i] = val[i].sgn;
		}
		return result;
	}

	/** combine two vectors */
	vec!(N, V) opBinary(string op)(vec!(N, V) rhs) const if (op == "-" || op == "+" || op == "*" || op == "/") {
		vec!(N, V) result;
		result.val[] = mixin("val[]" ~ op ~ "rhs.val[]");
		return result;
	}

	/** combine vector and scalar */
	vec!(N, V) opBinary(string op)(V rhs) const if (op == "-" || op == "+" || op == "*" || op == "/") {
		vec!(N, V) result;
		result.val[] = mixin("val[]" ~ op ~ "rhs");
		return result;
	}

	/* vector op= vector */
	auto opOpAssign(string op)(vec!(N, V) rhs) if (op == "-" || op == "+" || op == "*" || op == "/") {
		mixin("val[]" ~ op ~ "= rhs.val[];");
		return this;
	}

	/* vector op= scalar */
	auto opOpAssign(string op)(V rhs) if (op == "-" || op == "+" || op == "*" || op == "/") {
		mixin("val[]" ~ op ~ "= rhs;");
		return this;
	}

	string toString() const {
		bool first = true;
		char[] result = ['['];
		foreach(i; val) {
			if (!first) {
				result ~= ", ".dup;
			}
			first = false;
			result ~= to!string(i);
		}
		result ~= ']';
		return result.idup;
	}

	// use "auto ref const" to allow Lval and Rval here.
	int opCmp()(auto ref const vec!(N, V) s) const {
		for(int i = N - 1; i >= 0; --i) {
			if (s.val[i] > val[i]) return -1;
			if (s.val[i] < val[i]) return 1;
		}
		return 0;
	}

	/** 
	 * Create a copy of this point that stays between 0,0 and size,
	 * by taking the modulo of each coordinate.
	 * 
	 * Params:
	 *   size = area to keep the wrapped vector inside of.
	 * Returns: new point that is between 0,0 (inclusive) and size (exclusive).
	 */
	vec!(N, V) wrap(const vec!(N, V) size) const {
		vec!(N, V) result = this;
		foreach(i; 0..N) {
			result.val[i] %= size.val[i];
			// If modulo of a negative number - simply need to add size again.
			if (result.val[i] < 0) result.val[i] += size.val[i];
		}
		return result;
	}

	/** 
	 * Basis voor pythagoras. 
	 * Returns: Sum of the squares of each coordinate.
	 */
	V sumSq() {
		V sum = 0;
		foreach(i; 0..N) {
			sum += val[i] * val[i];
		}
		return sum;
	}

	/** 
	 * Length of the vector, a.k.a. hypothenuse, following pythagoras.
	 * Returns: length of the vector.
	 */
	double length() {
		import std.math : sqrt;
		return sqrt(to!double(sumSq()));
	}
}

unittest {
	assert (Point(2, 0) > Point(1, 0));
	assert (Point(0, 2) >= Point(0, 1));
	assert (Point(1, 0) < Point(0, 2));
	assert (Point(1, 0) == Point(1, 0));
	assert (Point(1, 0) <= Point(1, 0));
}

alias vec2i = vec!(2, int);
alias Point = vec!(2, int);
alias vec3i = vec!(3, int);
alias vec4i = vec!(4, int);

unittest {
	// shortcut accesors

	auto a = Point(3, 5);
	assert(a.x == 3);
	assert(a.y == 5);
	
	// assigning a property
	a.x = 9;
	assert(a.x == 9);

	// modifying a property
	a.x++;
	assert(a.x == 10);
	
	a.x += 20;
	assert(a.x == 30);

	// what can be achieved using const values
	const b = Point(7, 11);
	assert(b.x == 7);
	assert(b.x + 8 == 15);

	immutable c = Point(9, 10);
	assert(c.x == 9);
	// not possible on const objects
	// b.y++;
	// b.y += 10;
	// b = Point(10, 10);
}

unittest {
	Point a = Point(3, 4);

	// opOpAssign two points
	a += Point(2, -1);
	assert(a == Point(5, 3));

	// opOpAssign with scalar
	a *= 5;
	assert(a == Point(25, 15));
}

unittest {
	Point size = Point(16, 64);
	assert(Point(8,8).wrap(size) == Point(8,8));
	assert(Point(100,100).wrap(size) == Point(4,36));
	assert(Point(0,0).wrap(size) == Point(0,0));
	assert(Point(-1,-1).wrap(size) == Point(15,63));
	assert(Point(-16,-64).wrap(size) == Point(0,0));
	assert(Point(-17,-65).wrap(size) == Point(15,63));
}


unittest {
	import std.math : abs;
	assert(Point(8,6).sumSq() == 100);
	assert(abs(Point(4, 3).length()) - 5 < 0.01);
}