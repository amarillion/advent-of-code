#!/usr/bin/env -S rdmd -I..

import common.io;
import std.stdio;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.format : formattedRead;
import std.exception;

//TODO: why is this not in standard library?
ulong indexOf(int[] array, int needle) {
	foreach(i, a; array) {
		if (a == needle) {
			return i;
		}
	}
	return -1;
}

void playRound(ref int[] cups, ref int pos, int move) {
	
	writefln("-- Move %s --", move+1);
	foreach(i, cup; cups) {
		writef(i == pos ? "(%s) " : "%s ", cup);
	}
	writeln();

	int numCups = cast(int)cups.length;

	// re-arrange so that pos is first
	int[] temp = cups[pos..$] ~ cups[0..pos];
	
	// take 3 out
	int[] taken = temp[1..4];
	temp = temp[0] ~ temp[4..$];
	writeln("Pick up: ", taken);

	// select destination.
	int destNumber = temp[0];
	int destPos;
	do {
		destNumber -= 1;
		if (destNumber <= 0) destNumber += numCups;
		destPos = cast(int)temp.indexOf(destNumber);
	} while (destPos < 0);
	writeln("Destination: ", destNumber);

	// re-insert taken
	temp = temp[0..destPos+1] ~ taken ~ temp[destPos+1..$];

	// now shuffle back so that pos is in the middle
	cups = temp[$-pos..$] ~  temp[0..$-pos];

	// adjust pos
	pos = (pos + 1) % numCups;
}

void main() {

	int[] cups = readLines("input")[0].map!(ch => to!int(ch - '0')).array;
	int pos = 0;
	foreach (round; 0 .. 100) {
		playRound(cups, pos, round);
	}

	writeln("Final result:");

	ulong split = cups.indexOf(1);
	cups = cups[split+1..$] ~ cups[0..split];
	writeln(format("%(%s%)", cups));	
}
