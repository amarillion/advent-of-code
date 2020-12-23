#!/usr/bin/env -S rdmd -I..

import common.io;
import std.stdio;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.format : formattedRead;
import std.exception;

enum part1 = false;

//TODO: why is this not in standard library?
int indexOf(int[] array, int needle) {
	foreach(i, a; array) {
		if (a == needle) {
			return cast(int)i;
		}
	}
	return -1;
}

int max(int[] array) {
	int m = array[0];
	foreach(i; array[1..$]) {
		if (i > m) {
			m = i;
		}
	}
	return m;
}

int getCircular(ref int[] buffer, size_t pos) {
	return buffer[pos % buffer.length];
}

// ulong indexOfCiruclar(ref int[] buffer, ulong start, int needle) {
// 	foreach(i; 0..buffer.length) {
// 		ulong pos = (i + start) % data.length;
// 		if (buffer[pos] == needle) { return pos; }
// 	}
// 	return -1;
// }

void copyRange(ref int[] buffer, size_t start, size_t dest, size_t num) {
	assert (start > dest); // otherwise, copy in reverse order?
	// int[] before = buffer.dup;
	// foreach (i; 0 .. num) {
	// 	buffer[i + dest] = buffer[i + start];
	// }
	buffer[dest .. dest + num] = buffer [start .. start + num];
	// writefln("copying num: %s from %s to %s, %s => %s", num, start, dest, before, buffer);
}

void playRound(ref int[] cups, ref size_t pos, int move) {
	enum log = part1;

	// NB: cups is always arranged so that pos is first.
	// pos is just there for display purposes...

	size_t numCups = cups.length;
	
	if (log) {
		writefln("-- Move %s --", move+1);
		foreach(i; 0..numCups) {
			size_t virtualPos = (i + numCups - pos) % numCups;
			writef(virtualPos == 0 ? "(%s) " : "%s ", cups[virtualPos]);
		}
		writeln();
		writeln(cups);
	}
	// readln();

	// take 3 out
	int[] taken = cups[1..4].dup;
	if (log) writeln("pick up: ", taken);

	// select destination.
	int first = cups[0];
	int destNumber = first;
	do {
		destNumber -= 1;
		if (destNumber <= 0) destNumber += numCups;
	} while (taken.indexOf(destNumber) >= 0);
	
	size_t destPos = cups.indexOf(destNumber);
	if (log) writeln("Destination: ", destNumber, " pos ", destPos);
	
	// now re-shuffle
	/*
	copyRange(cups, 4, 0, (destPos - 3));
	cups[destPos - 3] = taken[0];
	cups[destPos - 2] = taken[1];
	cups[destPos - 1] = taken[2];
	copyRange(cups, destPos + 1, destPos, numCups - destPos - 1);
	cups[$-1] = first;
	*/
	// This also works...
	cups = cups[4 .. destPos+1] ~ taken ~ cups[destPos + 1 .. $] ~ cups[0];

	// adjust pos
	pos = (pos + 1) % numCups;

}

void main() {
	
	enum ROUNDS = part1 ? 100 : 10_000_000;
	bool FILL = !part1;
	
	int[] data = readLines("input")[0].map!(ch => to!int(ch - '0')).array;
	
	if (FILL) {
		int i = cast(int)data.length;
		int p = data.max() + 1;
		data.length = 1_000_000;
		for(; i < data.length; ++i, ++p) {
			data[i] = p;
		}
	}

	int[] cups = data;

	size_t pos = 0;
	foreach (round; 0 .. ROUNDS) {
		playRound(cups, pos, round);

		if (round % 10_000 == 0) {
			size_t split = cups.indexOf(1);
			writefln("Round %s. Split - %s: %s * %s = %s", round, split, cups[split+1], cups[split+2], cups[split+1] * cups[split+2]);
		}
	}

	writeln("Final result:");

	size_t split = cups.indexOf(1);
	writeln(split);
	
	if (part1) {
	// part 1
		cups = cups[split+1..$] ~ cups[0..split];
		writeln(format("%(%s%)", cups));	
	}
	else {
		// part 2
		writeln(cups[split+1], " * ", cups[split+2], " = ", cups[split+1] * cups[split+2]);
	}
}
