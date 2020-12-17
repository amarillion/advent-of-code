#!/usr/bin/env rdmd
import std.stdio;
import std.string;
import std.conv;

struct vec(int N, V) {
	V[N] val;
	
	@property V x() const { return val[0]; }
	@property void x(V v) { val[0] = v; }
	
	@property V y() const { return val[1]; }
	@property void y(V v) { val[1] = v; }

	static if (N > 2) {
		@property V z() const { return val[2]; }
		@property void z(V v) { val[2] = v; }
	}

	static if (N > 3) {
		@property V w() const { return val[3]; }
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

	void lowestCorner(U)(vec!(N, U) p) {
		foreach (i; 0..N) {
			if (p.val[i] < val[i]) { val[i] = p.val[i]; }
		}
	}

	void highestCorner(U)(vec!(N, U) p) {
		foreach (i; 0..N) {
			if (p.val[i] > val[i]) { val[i] = p.val[i]; }
		}
	}

	/** addition */
	vec!(N, V) opBinary(string op)(vec!(N, V) rhs) const if (op == "+") {
		vec!(N, V) result;
		foreach (i; 0..N) {
			result.val[i] = val[i] + rhs.val[i];
		}
		return result;
	}

	/** substraction */
	vec!(N, V) opBinary(string op)(vec!(N, V) rhs) const if (op == "-") {
		vec!(N, V) result;
		foreach (i; 0..N) {
			result.val[i] = val[i] - rhs.val[i];
		}
		return result;
	}

	/** add a scalar */
	vec!(N, V) opBinary(string op)(V rhs) const if (op == "+") {
		vec!(N, V) result;
		foreach (i; 0..N) {
			result.val[i] = val[i] + rhs;
		}
		return result;
	}

	/** substract a scalar */
	vec!(N, V) opBinary(string op)(V rhs) const if (op == "-") {
		vec!(N, V) result;
		foreach (i; 0..N) {
			result.val[i] = val[i] - rhs;
		}
		return result;
	}
}

alias vec3i = vec!(3, int);
alias vec4i = vec!(4, int);

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

	void echo() {
		int i = 0;
		const T size = (max - min) + 1;
		const int lineSize = size.x;
		const int blockSize = size.x * size.y;
		foreach (base; CoordRange!T(min, max)) {
			if (i % lineSize == 0) {
				writeln();
			}
			if (i % blockSize == 0) {
				writeln(base);
			}
			const char ch = get(base) ? '#' : '.';
			write(ch);
			i++;
		}
		writeln();
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

void readFromFile(T)(SparseInfiniteGrid!(T,bool) grid, string fname) {
	File file = File(fname, "rt");
	int y = 0;
	while (!file.eof()) {
		string line = chomp(file.readln()); 
		if (line.length == 0) break;
		int x = 0;
		foreach (char ch; line) {
			bool val = ch == '#';
			T pos;
			pos.x = x; pos.y = y;
			grid.set(pos, val);
			x++;
		}
		y++;
	}
}

void main()
{
	bool transformCell(T, U)(U grid, T p) {
		int count = 0;
		foreach (d; CoordRange!T(T(-1), T(1))) {
			if (d == T(0)) continue;
			if (grid.get(p + d)) {
				count++;
			}
		}
		const bool current = grid.get(p);
		return ((current && count == 2) || count == 3);
	}

	string fname = "input";
	
	// Part 1:
	auto grid3 = new SparseInfiniteGrid!(vec3i, bool)();
	grid3.readFromFile(fname);
	
	grid3.echo();
	foreach (i; 0 .. 6) {
		grid3.transform((p) => transformCell(grid3, p));
		writeln(grid3.data.length);
	}
	grid3.echo();
	
	writeln("Part 1: ", grid3.data.length);

	auto grid4 = new SparseInfiniteGrid!(vec4i, bool)();
	grid4.readFromFile(fname);
	foreach (i; 0 .. 6) {
		grid4.transform((p) => transformCell(grid4, p));
	}
	// grid4.echo();
	writeln("Part 2: ", grid4.data.length);


}
