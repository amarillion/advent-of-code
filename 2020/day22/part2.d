#!/usr/bin/env -S rdmd -I..

module day22.part2;

import common.io;
import std.stdio;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.format : formattedRead;
import std.exception;

int game = 0;

long calculateScore(int[] player) {
	long sum = 0;
	ulong cardNum = player.length;
	foreach(i, j; player) {
		sum += ((cardNum-i) * j);
	}
	return sum;
}

enum bool log = false;

// NOTE: player cards are modified in place. Duplicate before recursive call...
int playGame(ref int[][2] player, int callerGame) {
	
	string[string] playedRounds;

	int myGame = ++game;
	if(log) writefln("=== Game %s ===", game);
	
	int round = 1;
	int winner;
		
	while(!(player[0].empty || player[1].empty)) {
		if(log) writefln("-- Round %s Game %s --", round, myGame);
		foreach (p; 0..2) {
			if(log) writefln("Player %s deck: %s", p+1, player[p]);
		}
		
		string key = to!string(player);
		if (key in playedRounds) {
			if(log) writefln("Deja Vu at %s, declaring Player 1 the winner!", playedRounds[key]);
			return 0;
		}
		playedRounds[key] = format("Round %s Game %s", round, myGame);

		int[] taken;

		foreach (p; 0..2) {
			if(log) writefln("Player %s plays %s", p+1, player[p][0]);
			taken ~= player[p][0];
			player[p] = player[p][1..$];
		}
		
		if (taken[0] <= player[0].length && taken[1] <= player[1].length) {
			int[][2] copy = player.dup;
			// shorten to match card id
			copy[0].length = taken[0];
			copy[1].length = taken[1];
			if(log) writeln("Playing new game to determine winner");
			winner = playGame(copy, myGame);
		}
		else {
			if (taken[0] > taken[1]) {
				winner = 0;
			}
			else {
				winner = 1;
			}
		}

		if(log) writefln("Player %s wins the round!", winner+1);
		if (winner == 0) {
			player[winner] ~= taken;
		}
		else {
			player[winner] ~= reverse(taken);
		}
		
		if(log) writeln();
		round++;
		// readln();
	}

	if (callerGame > 0) {
		if(log) writefln("Back to game %s", callerGame);
	}

	return winner;
}

void main() {

	File file = File("input", "rt");
	int[][2] player;
	player[0] = readParagraph(file)[1..$].map!(to!int).array;
	player[1] = readParagraph(file)[1..$].map!(to!int).array;	

	int winner = playGame(player, 0);

	writeln("=== Post-Game Results ===");
	foreach (p; 0..2) {
		writefln("Player %s deck: %s", p+1, player[p]);
	}
	// winner is still valid...
	long sum = calculateScore(player[winner]);
	writeln(sum);
}

// answered: 2632: too low...