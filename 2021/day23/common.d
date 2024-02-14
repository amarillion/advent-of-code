module day23.common;

import std.algorithm;

enum int[char] podCosts = [
	'A': 1, 'B': 10, 'C': 100, 'D': 1000
];

struct Pod {
	char type;
	int pos;

	this(char type, int pos) {
		assert(['A', 'B', 'C', 'D'].canFind(type), "Wrong type " ~ type);
		this.type = type;
		this.pos = pos;
	}
}

struct Move {
	int cost;
	Pod from;
	int to;
}
