#!/usr/bin/env -S rdmd -I..

import common.io;
import std.stdio;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.format : formattedRead;
import std.exception;
import std.range;

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

struct RingBuffer {
	private size_t[int] searchIdx;
	int[] data;

	size_t pos = 0;
	
	this(int[] data, size_t pos = 0) {
		this.data = data;
		this.pos = pos;
		foreach (i, j; data) {
			searchIdx[j] = i;
		}
	}

	@property size_t length() {
		return data.length;
	}

	int get(size_t idx) {
		ulong p = (pos + idx) % data.length;
		return data[p];
	}

	void set(size_t idx, int val) {
		ulong p = (pos + idx) % data.length;
		data[p] = val;
		searchIdx[val] = p;
	}

	long indexOf(int needle) const {
		size_t len = data.length;
		if (needle in searchIdx) {
			return (len + searchIdx[needle] - pos) % len;
		}
		return -1;
	}

	void copyRangeReverse(size_t _src, size_t _dest, size_t num) {
		// writefln("copyRangeReverse(%s, %s, %s)", _src, _dest, num);
		for (size_t i = num; i > 0; i--) {
			// int[] before = data.dup;
			// int datum = get(i - 1 + _src);
			set(i + _dest, get(i - 1 + _src));
			// writefln("Copying '%s' from %s to %s: %s => %s", datum, i - 1 + _src, i - 1 + _dest, before, data);
		}
	}


	void copyRange(size_t _src, size_t _dest, size_t num) {
		// writefln("copyRange(%s, %s, %s)", _src, _dest, num);
		foreach (i; 0 .. num) {
			// int[] before = data.dup;
			// int datum = get(i + _src);
			set(i + _dest, get(i + _src));
			// writefln("Copying '%s' from %s to %s: %s => %s", datum, i + _src, i + _dest, before, data);
		}

	/*
		// copy a bit
		size_t remain = num;
		size_t len = buffer.data.length;
		size_t src = (_src + buffer.pos) % len;
		size_t dest = (_dest + buffer.pos) % len;
		// writefln("%s %s %s", src, dest, num);
		while (remain > 0) {
			// copy suitable section
			size_t amount = min(remain, len - src, len - dest);
			// int[] before = buffer.data;
			// writefln("Copying %s from %s to %s; %s => %s", amount, src, dest, before, buffer.data);
			// writeln(buffer.data[dest..dest + amount]);
			// writeln(buffer.data[src..src + amount]);

			// int[] temp = buffer.data[src..src + amount].dup;
			// buffer.data[dest..dest + amount] = temp;

			// can't copy overlapping ranges this way???
			// buffer.data[dest..dest + amount] = buffer.data[src..src + amount];

			src = (src + amount) % len;
			dest = (dest + amount) % len;
			remain -= amount;
		}
	*/
	}

}

unittest {
	auto buffer = RingBuffer(10.iota.array, 5L);
	assert (buffer.get(0) == 5);
	assert (buffer.get(5) == 0);
}

void copyRange(ref int[] buffer, size_t src, size_t dest, size_t num) {
	assert (src > dest); // otherwise, copy in reverse order?
	// int[] before = buffer.dup;
	// foreach (i; 0 .. num) {
	// 	buffer[i + dest] = buffer[i + start];
	// }
	buffer[dest .. dest + num] = buffer [src .. src + num];
	// writefln("copying num: %s from %s to %s, %s => %s", num, start, dest, before, buffer);
}

unittest {
	auto buffer = RingBuffer(4.iota.array, 0);
	assert(buffer.data == [0, 1, 2, 3]);
	buffer.copyRange(1, 0, 2);
	assert(buffer.data == [1, 2, 2, 3]);
	
	// TODO: edge case
	// buffer = RingBuffer(4.iota.array, 0);
	// buffer.copyRange(3, 0, 2);
	// writeln(buffer.data);
	// assert(buffer.data == [3, 0, 2, 3]);

	buffer = RingBuffer(4.iota.array, 3);
	buffer.copyRange(1, 0, 2);
	assert(buffer.data == [1, 1, 2, 0]);

}

alias Cups = RingBuffer;

void playRound(ref Cups cups, int move, bool log = false) {
	// NB: cups is always arranged so that pos is first.
	// pos is just there for display purposes...

	size_t numCups = cups.length;
	
	if (log) {
		writefln("-- Move %s --", move+1);
		foreach(i, cup; cups.data) {
			writef(i == cups.pos ? "(%s) " : "%s ", cup);
		}
		writeln();
	}

	// take 3 out
	int[] taken = [
		cups.get(1L),
		cups.get(2L),
		cups.get(3L)
	];
	
	if (log) writeln("pick up: ", taken);

	// select destination.
	int first = cups.get(0L);
	int destVal = first;
	do {
		destVal -= 1;
		if (destVal <= 0) destVal += numCups;
	} while (taken.indexOf(destVal) >= 0);
	
	size_t destPos = cups.indexOf(destVal);
	if (log) writeln("Destination: ", destVal, " pos ", destPos);
	
	size_t leftPart = destPos - 3;
	size_t rightPart = numCups - destPos;
	// writefln("Copying %s and %s", leftPart, rightPart);

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
	// cups = cups[4 .. destPos+1] ~ taken ~ cups[destPos + 1 .. $] ~ cups[0];

	// adjust pos


	if (rightPart > leftPart) {

		cups.copyRange(4, 1, (destPos - 3));
		// cups.set(destPos - 3, destVal); // redundant
		cups.set(destPos - 2, taken[0]);
		cups.set(destPos - 1, taken[1]);
		cups.set(destPos - 0, taken[2]);

		cups.pos = (cups.pos + 1) % numCups;
		// cups.set(pos, 0, destVal);
	}
	else {
		cups.copyRangeReverse(destPos + 1, destPos + 3, (numCups - destPos));
		cups.set(destPos + 1, taken[0]);
		cups.set(destPos + 2, taken[1]);
		cups.set(destPos + 3, taken[2]);

		cups.pos = (cups.pos + numCups - 5) % numCups;
	}

	// writeln(cups.data, cups.pos);
}

int[] part1result (ref RingBuffer cups) {
	size_t split = cups.data.indexOf(1);
	return cups.data[split+1..$] ~ cups.data[0..split];
}

unittest {
	// test case
	auto cups = Cups([3, 8, 9, 1, 2, 5, 4, 6, 7]);
	foreach (round; 0..100) {
		playRound(cups, round);
	}
	assert(cups.part1result == [6, 7, 3, 8, 4, 5, 2, 9]);

	// input case
	cups = Cups([4, 6, 3, 5, 2, 8, 1, 7, 9]);
	foreach (round; 0..100) {
		playRound(cups, round);
	}
	assert(cups.part1result == [5, 2, 9, 3, 7, 8, 4, 6]);
}

void main() {
	
	enum ROUNDS = part1 ? 100 : 10_000_000;
	bool FILL = !part1;
	
	int[] data = readLines("test")[0].map!(ch => to!int(ch - '0')).array;
	
	if (FILL) {
		int i = cast(int)data.length;
		int p = data.max() + 1;
		data.length = 1_000_000;
		for(; i < data.length; ++i, ++p) {
			data[i] = p;
		}
	}

	auto cups = Cups(data);
	foreach (round; 0 .. ROUNDS) {
		playRound(cups, round, part1);

		if (round % 1000 == 0) {
			if (round % 20_000 == 0) {
				writeln();
				writeln(round);
			}
			write('.');
			stdout.flush();
		}		

	}

	writeln("Final result:");

	size_t split = cups.data.indexOf(1);

	if (part1) {
	// part 1
		int[] output = cups.data[split+1..$] ~ cups.data[0..split];
		writeln(format("%(%s%)", output));
	}
	else {
		// part 2
		writeln(cups.data[split+1], " * ", cups.data[split+2], " = ", cups.data[split+1] * cups.data[split+2]);
	}
}
