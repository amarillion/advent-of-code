#!/usr/bin/env rdmd
import std.stdio;
import std.string;
import std.conv;

struct vec(int N) {
	int[N] val;
	
	@property int x() const { return val[0]; }
	@property void x(int v) { val[0] = v; }
	
	@property int y() const { return val[1]; }
	@property void y(int v) { val[1] = v; }

	static if (N > 2) {
		@property int z() const { return val[2]; }
		@property void z(int v) { val[2] = v; }
	}

	static if (N > 3) {
		@property int w() const { return val[3]; }
		@property void w(int v) { val[3] = v; }
	}

	this(int x, int y, int z = 0, int w = 0) {
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

	this(int init) {
		foreach (i; 0..N) {
			val[i] = init;
		}
	}

	void lowestCorner(vec!N p) {
		foreach (i; 0..N) {
			if (p.val[i] < val[i]) { val[i] = p.val[i]; }
		}
	}

	void highestCorner(vec!N p) {
		foreach (i; 0..N) {
			if (p.val[i] > val[i]) { val[i] = p.val[i]; }
		}
	}

	vec!N opBinary(string op)(vec!N rhs) const if (op == "+") {
		vec!N result;
		foreach (i; 0..N) {
			result.val[i] = val[i] + rhs.val[i];
		}
		return result;
	}

	vec!N opBinary(string op)(vec!N rhs) const if (op == "-") {
		vec!N result;
		foreach (i; 0..N) {
			result.val[i] = val[i] - rhs.val[i];
		}
		return result;
	}

	vec!N opBinary(string op)(int rhs) const if (op == "+") {
		vec!N result;
		foreach (i; 0..N) {
			result.val[i] = val[i] + rhs;
		}
		return result;
	}

	vec!N opBinary(string op)(int rhs) const if (op == "-") {
		vec!N result;
		foreach (i; 0..N) {
			result.val[i] = val[i] - rhs;
		}
		return result;
	}
}

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

class SparseInfiniteGrid(T) {

	bool[T] data;
	T min;
	T max;

	bool get(T p) {
		if (p in data) {
			return data[p];
		}
		else {
			return false;
		}
	}

	void set(T p, bool val) {
		min.lowestCorner(p);
		max.highestCorner(p);
		data[p] = val;
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

	void transform() {
		auto newData = new SparseInfiniteGrid!T();
		foreach (p; CoordRange!T(min - 1, max + 1)) {
			int count = 0;
			foreach (d; CoordRange!T(T(-1), T(1))) {
				if (d == T(0)) continue;
				if (get(p + d)) {
					count++;
				}
			}
			const bool current = get(p);
				
			if ((current && count == 2) || count == 3) {
				newData.set(p, true);				
			}
		}
		data = newData.data;
		min = newData.min;
		max = newData.max;		
	}

	void readFromFile(string fname) {
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
				set(pos, val);
				x++;
			}
			y++;
		}
	}
}

void main()
{
	string fname = "input";
	// Part 1:
	auto grid3 = new SparseInfiniteGrid!(vec!3)();
	grid3.readFromFile(fname);
	
	grid3.echo();
	foreach (i; 0 .. 6) {
		grid3.transform();
	}
	grid3.echo();
	
	writeln("Part 1: ", grid3.data.length);

	auto grid4 = new SparseInfiniteGrid!(vec!4)();
	grid4.readFromFile(fname);
	foreach (i; 0 .. 6) {
		grid4.transform();
	}
	// grid4.echo();
	writeln("Part 2: ", grid4.data.length);


}
