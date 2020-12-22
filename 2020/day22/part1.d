#!/usr/bin/env -S rdmd -I..

module day21.part1;

import common.io;
import std.stdio;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.format : formattedRead;

void main() {

	File file = File("input", "rt");
	int[][2] player;
	player[0] = readParagraph(file)[1..$].map!(to!int).array;
	player[1] = readParagraph(file)[1..$].map!(to!int).array;	

	writeln(player);

	int round = 1;
	int winner;
		
	while(!(player[0].empty || player[1].empty)) {
		writefln("-- Round %s --", round);
		foreach (p; 0..2) {
			writefln("Player %s deck: %s", p+1, player[p]);
		}
		
		int[] taken;

		foreach (p; 0..2) {
			writefln("Player %s plays %s", p+1, player[p][0]);
			taken ~= player[p][0];
			player[p] = player[p][1..$];
		}
		
		if (taken[0] > taken[1]) {
			winner = 0;
		}
		else {
			winner = 1;
		}

		writefln("Player %s wins the round!", winner);
		taken = reverse(sort(taken)).array;
		player[winner] ~= taken;

		writeln();
		round++;
	}

	writeln("=== Post-Game Results ===");
	foreach (p; 0..2) {
		writefln("Player %s deck: %s", p+1, player[p]);
	}
	// winner is still valid...
	long sum;
	ulong cardNum = player[winner].length;
	foreach(i, j; player[winner]) {
		sum += ((cardNum-i) * j);
	}
	writeln(sum);
}