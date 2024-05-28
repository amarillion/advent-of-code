#!/usr/bin/env -S rdmd -I..
module day6.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;

import common.io;
import common.vec;
import common.box;

alias Data = vec2i[];
Data parse(string fname) {
	string[] lines = readLines(fname);
	Data data;
	foreach(line; lines) {
		auto parts = line.split(", ");
		auto x = to!int(parts[0]);
		auto y = to!int(parts[1]);
		data ~= vec2i(x, y);
	}
	return data;
}

vec2i[] getClosest(vec2i pos, Data data) {
	int minDist;
	bool first = true;
	vec2i[] result;
	foreach(p; data) {
		int dist = manhattan(pos - p);
		if (first || dist < minDist) {
			result = [ p ];
			minDist = dist;
		}
		else if (dist == minDist) {
			result ~= p;
		}
		first = false;
	}
	return result;
}

auto solve1(Data data) {
	int[vec2i] counts;
	bool[vec2i] isInfinite;
	
	Rect!int bounds = Rect!int(
		// TODO: need constructor with 4 values...
		vec2i(data.map!(p => p.x).minElement - 1, data.map!(p => p.y).minElement - 1),
		vec2i(data.map!(p => p.x).maxElement + 1, data.map!(p => p.y).maxElement + 1)
	);
	foreach(pos; bounds.coordrange) {
		vec2i[] close = getClosest(pos, data);
		if (close.length == 1) {
			auto closest = close[0];
			if (closest in counts) { 
				counts[closest]++; 
			} else {
				counts[closest] = 1;
			}
			if(pos.x == 0 || pos.x == bounds.size.x-1 || pos.y == 0 || pos.y == bounds.size.y - 1) {
				isInfinite[closest] = true;
			}
		}
	}

	int maxCount = 0;
	// TODO: declarative way to get max value
	foreach(p, count; counts) {
		if (p !in isInfinite) {
			maxCount = max(maxCount, count);
		}
	}
	return maxCount;
}

// part 2: 08:28-
auto solve2(Data data, int limit) {
	bool[vec2i] visited;
	bool[vec2i] checked; // TODO: avoid need for extra 'checked' map?
	
	int len = to!int(data.length);
	vec2i start = vec2i(
		data.map!(i => i.x).sum / len,
		data.map!(i => i.x).sum / len,
	);
	vec2i[] open = [ start ];
	
	// do a bfs
	// TODO: re-usable bfs function
	while (!open.empty) {
		vec2i current = open.front;
		open.popFront;

		visited[current] = true;

		vec2i delta = vec2i(0, 1);
		foreach(i; 0..4) { //TODO: use cardinals
			vec2i npos = current + delta;

			// rotate 90 degrees. TODO: helper
			delta = vec2i(delta.y, -delta.x); 

			if (npos in checked) { continue; }
			checked[npos] = true;

			if (npos in visited) { continue; }
			int sumlen = data.map!(p => manhattan(npos - p)).sum;
			// writefln("Trying %s sum: %s, visited: %s", npos, sumlen, visited.length);
			if (sumlen >= limit) { continue; }

			open ~= npos;
		}
	}

	return visited.length;
}

void main(string[] args) {
	assert(args.length == 2, "Expecting 1 argument: input file");
	auto data = parse(args[1]);
	writeln(solve1(data));
	writeln(solve2(data, 32));
	writeln(solve2(data, 10000));
}
