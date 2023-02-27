#!/usr/bin/env -S rdmd -I..

import common.vec;
import std.stdio;
import std.file;
import std.range;

auto visit(R)(R data, ref bool[Point] visited) {
	Point pos = 0;
	visited[pos] = true;
	foreach(dchar dir; data) {
		switch(dir) {
			case '^': pos.y -= 1; break;
			case '>': pos.x += 1; break;
			case 'v': pos.y += 1; break;
			case '<': pos.x -= 1; break;
			default: break; // skip
		}
		visited[pos] = true;
	}
	return visited.length;
}

auto solve(string data) {
	bool[Point] visited1, visited2;
	visit(data, visited1);
	visit(stride(data, 2), visited2);
	visit(stride(data[1..$], 2), visited2);
	return [ visited1.length, visited2.length ];
}

void main() {
	assert(solve(">") == [2, 2]);
	assert(solve("^>v<") == [4, 3]);
	assert(solve("^v^v^v^v^v") == [2, 11]);
	writeln(solve(readText("input")));
}