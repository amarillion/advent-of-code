#!/usr/bin/env -S rdmd -g -I..
module day23.solution;

import std.stdio;
import common.io;

import part1 = day23.part1;
import part2 = day23.part2;

void main(string[] args) {
	assert(args.length == 2, "Argument expected: input file");
	
	string[] lines = readLines(args[1]);
	string[] lines2 = lines[0..3] ~ ["  #D#C#B#A#", "  #D#B#A#C#" ] ~ lines[3..$];

	writeln ([
		part1.solve(lines),
		part2.solve(lines2)
	]);
}
