#!/usr/bin/env -S rdmd -I..
module day9.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;

import common.io;

struct Data {
	int numPlayers;
	int lastMarble;
}
Data parse(string fname) {
	string[] lines = readLines(fname);
	string[] fields = lines[0].split(" ");
	return Data(to!int(fields[0]), to!int(fields[6]));
}

auto solve1(Data data) {
	int[] q = [ 0 ];
	int current = 0;
	int[] players; players.length = data.numPlayers;

	// writeln(data);	
	// writeln("Turn: 0");
	// writeln(current);

	foreach(int turn; 1 .. data.lastMarble + 1) {
		int next = turn;
		if (next % 23 == 0) {
			int player = (turn % data.numPlayers);
			// writeln("Score by player: ", turn, " ", player);
			players[player] += next;
			int removalPos = (current + to!int(q.length) - 7) % to!int(q.length);
			players[player] += q[removalPos];
			q = q[0..removalPos] ~ q[(removalPos+1)..$];
			current = removalPos;
		}
		else {
			int insertionPos = (current + 1) % to!int(q.length) + 1;
			q = q[0..insertionPos] ~ next ~ q[insertionPos..$];
			current = insertionPos;
		}

		// writeln("Turn: ", turn);
		// writeln("Queue: ", q);
		// writeln(current);
		// writeln(remain);
		// writeln(players);

		turn++;

		if (turn % 100_000 == 0) {
			writefln("%s %s %2.2f%%", turn, data.lastMarble, turn * 100.0f / data.lastMarble);
		}
	}

	// writeln(players);
	return players.maxElement;
}

void main(string[] args) {
	assert(args.length == 2, "Expecting 1 argument: input file");
	auto data = parse(args[1]);
	writeln(solve1(data));
	writeln(solve1(Data(data.numPlayers, data.lastMarble * 100)));
}
