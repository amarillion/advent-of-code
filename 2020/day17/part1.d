#!/usr/bin/env rdmd
import std.stdio;
import std.string;
import std.conv;

struct vec3 {
	int x, y, z;
}

class SparseInfiniteGrid {

	bool[vec3] data;
	vec3 min;
	vec3 max;

	bool get(vec3 p) {
		if (p in data) {
			return data[p];
		}
		else {
			return false;
		}
	}

	void set(vec3 p, bool val) {
		if (p.x < min.x) { min.x = p.x; }
		if (p.y < min.y) { min.y = p.y; }
		if (p.z < min.z) { min.z = p.z; }
		if (p.x > max.x) { max.x = p.x; }
		if (p.y > max.y) { max.y = p.y; }
		if (p.z > max.z) { max.z = p.z; }
		data[p] = val;
	}

	void echo() {
		foreach (z; min.z .. max.z + 1) {
			writefln ("\nz = %s", z);
			foreach (y; min.y .. max.y + 1) {
				foreach (x; min.x .. max.x + 1) {
					char ch = get(vec3(x, y, z)) ? '#' : '.';
					write(ch);
				}
				writeln();
			}
		}
	}

	void transform() {
		auto newData = new SparseInfiniteGrid();
		foreach (x; min.x -1 .. max.x + 2) {
			foreach (y; min.y -1 .. max.y + 2) {
				foreach (z; min.z -1 .. max.z + 2) {
					int count = 0;
					foreach (dx; -1 .. 2) {
						foreach (dy; -1 .. 2) {
							foreach (dz; -1 .. 2) {
								if (dx == 0 && dy == 0 && dz == 0) continue;
								if (get(vec3(x+dx, y+dy, z+dz))) {
									count++;
								}
							}
						}
					}
					auto p = vec3(x, y, z);
					bool current = get(p);
					// writeln(p, " ", current, " count: ", count);
					if ((current && count == 2) || count == 3) {
						newData.set(p, true);
						// writeln("writing to ", p);
					}
				}
			}
		}
		data = newData.data;
		min = newData.min;
		max = newData.max;
	}
}

void main()
{
	auto grid = new SparseInfiniteGrid();

	File file = File("input", "rt");

	int y = 0;
	while (!file.eof()) {
		string line = chomp(file.readln()); 
		if (line.length == 0) break;
		int x = 0;
		foreach (char ch; line) {
			bool val = ch == '#';
			grid.set(vec3(x, y, 0), val);
			x++;
		}
		y++;
	}	
	grid.echo();
	
	foreach (i; 0 .. 6) {
		grid.transform();
	}

	grid.echo();
	writeln(grid.data.length);

}
