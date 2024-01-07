module common.grid;

import common.vec;
import common.coordrange;

import std.conv;

class Grid(int N, T) {
	T[] data;
	vec!(N, int) size;

	@property int width() const { return size.x; }
	@property int height() const { return size.y; }

	static if (N == 2) {
		this(int width, int height, T initialValue = T.init) {
			this(vec!(N, int)(width, height), initialValue);
		}
	}
	else static if (N == 3) {
		@property int depth() const { return size.z; }
		this(int width, int height, int depth, T initialValue = T.init) {
			this(vec!(N, int)(width, height, depth), initialValue);
		}
	}

	// copy constructor
	this(const Grid!(N, T) src) {
		data = src.data.dup;
		size = src.size;
		col = ColumnAccess(this);
		row = RowAccess(this);
	}

	// instantiate duplicate of this.
	Grid!(N, T) dup() const {
		return new Grid!(N, T)(this);
	}

	this(vec!(N, int) size, T initialValue = T.init) {
		this.size = size;
		data = [];
		data.length = size.x * size.y;
		if (initialValue !is T.init) {
			foreach(ref cell; data) {
				cell = initialValue;
			}
		}
		col = ColumnAccess(this);
		row = RowAccess(this);
	}

	bool inRange(vec!(N, int) p) const {
		auto zero = vec!(N, int)(0);
		return p.allGte(zero) && p.allLt(size);
	}

	size_t toIndex(vec!(N, int) p) const {
		size_t result = p.val[$ - 1];
		foreach (i; 1 .. N) {
			result *= size.val[$ - i - 1];
			result += p.val[$ - i - 1];
		}
		return result;
	}

	deprecated
	void set(const vec!(N, int) p, T val) {
		assert(inRange(p));
		data[toIndex(p)] = val;
	}

	deprecated
	ref T get(const vec!(N, int) p) {
		assert(inRange(p));
		return data[toIndex(p)];
	}

	// const version
	ref auto opIndex(const vec!(N, int) p) const {
		assert(inRange(p));
		return data[toIndex(p)];
	}

	// non-const version
	ref auto opIndex(const vec!(N, int) p) {
		assert(inRange(p));
		return data[toIndex(p)];
	}

	// TODO: also implement for N == 3...
	static if (N == 2) {
		string format(string cellSep = ", ", string lineSep = "\n") const {
			char[] result;
			int i = 0;
			
			const int lineSize = size.x;
			bool firstLine = true;
			bool firstCell = true;
			foreach (base; PointRange(size)) {
				if (i % lineSize == 0 && !firstLine) {
					result ~= lineSep;
					firstCell = true;
				}
				if (!firstCell) result ~= cellSep;
				result ~= to!string(this[base]);
				i++;
				
				firstLine = false;
				firstCell = false;
			}
			return result.idup;
		}

		override string toString() const {
			return format();
		}
	}

	struct ColumnAccess {
		private Grid!(N, T) parent;
		private this(Grid!(N, T) parent) { this.parent = parent; }

		NodeRange opIndex(int col) {
			return NodeRange(parent, parent.width, col, parent.height);
		}
	}
	ColumnAccess col;

	struct RowAccess {
		private Grid!(N, T) parent;
		private this(Grid!(N, T) parent) { this.parent = parent; }

		NodeRange opIndex(int row) {
			return NodeRange(parent, 1, parent.width * row, parent.width);
		}
	}
	RowAccess row;

	// TODO: const and non-const variants	
	struct NodeRange {

		Grid!(N, T) parent;
		int pos = 0;
		int stride = 1;
		int remain;

		this(Grid!(N, T) parent, int stride = 1, int start = 0, int num = -1) {
			this.parent = parent;
			this.stride = stride;
			this.pos = start;
			remain = num < 0 ? (to!int(parent.data.length) - start) / stride : num;
		}

		/* use ref to support in place-modification */
		ref T front() {
			return parent.data[pos];
		}

		void popFront() {
			pos += stride;
			remain--;
		}

		bool empty() const {
			return remain <= 0;
		}
		
	}

	NodeRange eachNode() {
		return NodeRange(this);
	}
	
	NodeRange eachNodeCheckered() {
		const PRIME = 523;
		assert(data.length % PRIME != 0);
		return NodeRange(this, PRIME);
	}
}

unittest {

	// toIndex test
	auto grid = new Grid!(3, bool)(32, 16, 4);

	assert (grid.toIndex(vec3i(0, 0, 0)) == 0);
	assert (grid.toIndex(vec3i(1, 0, 0)) == 1);
	assert (grid.toIndex(vec3i(0, 1, 0)) == 32);
	assert (grid.toIndex(vec3i(0, 0, 1)) == 32 * 16);
	assert (grid.toIndex(vec3i(7, 7, 3)) == 7 + (32 * 7) + (16 * 32 * 3));
}

unittest {
	// opIndex test
	auto grid2 = new Grid!(2, bool)(2, 2, false);
	assert (grid2[Point(0, 0)] == false);
	grid2[Point(0, 0)] = true;
	assert (grid2[Point(0, 1)] == false);

	const grid3 = grid2;
	assert (grid3[Point(0, 0)] == true);
	// grid3[Point(0, 0)] = false; // does not compile...	
}


unittest {
	auto grid = new Grid!(2, int)(3, 4);
	for (int y = 0; y < 4; ++y) {
		for (int x = 0; x < 3; ++x) {
			grid[Point(x, y)] = x * 3 + y * 5;
		}
	}

	import std.array;
	assert(grid.row[0].array == [0,3,6]);
	assert(grid.row[1].array == [5,8,11]);
	assert(grid.col[0].array == [0,5,10,15]);
	assert(grid.col[1].array == [3,8,13,18]);
}