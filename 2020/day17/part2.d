#!/usr/bin/env rdmd
import std.stdio;
import std.string;
import std.conv;

struct vec3 {
	int x, y, z;

	void lowestCorner(vec3 p) {
		if (p.x < x) { x = p.x; }
		if (p.y < y) { y = p.y; }
		if (p.z < z) { z = p.z; }
	}

	void highestCorner(vec3 p) {
		if (p.x > x) { x = p.x; }
		if (p.y > y) { y = p.y; }
		if (p.z > z) { z = p.z; }
	}
}

struct vec4 {
	int x, y, z, w;

	void lowestCorner(vec4 p) {
		if (p.x < x) { x = p.x; }
		if (p.y < y) { y = p.y; }
		if (p.z < z) { z = p.z; }
		if (p.w < w) { w = p.w; }
	}

	void highestCorner(vec4 p) {
		if (p.x > x) { x = p.x; }
		if (p.y > y) { y = p.y; }
		if (p.z > z) { z = p.z; }
		if (p.w > w) { w = p.w; }
	}
}

class SparseInfiniteGrid {

	bool[vec4] data;
	vec4 min;
	vec4 max;

	bool get(vec4 p) {
		if (p in data) {
			return data[p];
		}
		else {
			return false;
		}
	}

	void set(vec4 p, bool val) {
		min.lowestCorner(p);
		max.highestCorner(p);
		data[p] = val;
	}

	void echo() {
		foreach (w; min.w .. max.w + 1) {
			foreach (z; min.z .. max.z + 1) {
				writefln ("\nz=%s, w=%s", z, w);
				foreach (y; min.y .. max.y + 1) {
					foreach (x; min.x .. max.x + 1) {
						char ch = get(vec4(x, y, z, w)) ? '#' : '.';
						write(ch);
					}
					writeln();
				}
			}
		}
	}

	void transform() {
		auto newData = new SparseInfiniteGrid();
		foreach (x; min.x -1 .. max.x + 2) {
			foreach (y; min.y -1 .. max.y + 2) {
				foreach (z; min.z -1 .. max.z + 2) {
					foreach (w; min.w -1 .. max.w + 2) {
						int count = 0;
						foreach (dx; -1 .. 2) {
							foreach (dy; -1 .. 2) {
								foreach (dz; -1 .. 2) {
									foreach (dw; -1 .. 2) {
										if (dx == 0 && dy == 0 && dz == 0 && dw == 0) continue;
										if (get(vec4(x+dx, y+dy, z+dz, w + dw))) {
											count++;
										}
									}
								}
							}
						}

						auto p = vec4(x, y, z, w);
						bool current = get(p);
						if ((current && count == 2) || count == 3) {
							newData.set(p, true);
						}
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
			grid.set(vec4(x, y, 0, 0), val);
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
