#!/usr/bin/env -S rdmd -I..

import common.io;
import common.grid;
import common.vec;
import std.stdio;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.format : formattedRead;
import std.exception;

long transformSubject(long subjectNumber, long loopSize) {

	long val = 1;
	foreach (i; 0..loopSize) {
		val *= subjectNumber;
		val = val % 20201227;
	}
	return val;
}

unittest {
	assert (transformSubject(7, 8) == 5764801);
	assert (transformSubject(7, 11) == 17807724);
	assert (transformSubject(17807724, 8) == 14897079);
	assert (transformSubject(5764801, 11) == 14897079);
}

long findLoopSize(long subjectNumber, long publicKey) {
	
	long val = 1;
	for(long i = 1;; ++i) {
		val *= subjectNumber;
		val = val % 20201227;
		if (val == publicKey) {
			return i;
		}
	}
}

unittest {
	assert (findLoopSize(7, 5764801) == 8);
	assert (findLoopSize(7, 17807724) == 11);
}

void main() {

	long[] keys = readLines("input").map!(to!long).array;
	
	long[2] loopSize;
	loopSize[0] = findLoopSize(7, keys[0]);
	loopSize[1] = findLoopSize(7, keys[1]);
	
	long[2] encryption;
	encryption[0] = transformSubject(keys[0], loopSize[1]);
	encryption[1] = transformSubject(keys[1], loopSize[0]);
	
	writeln("Final result:");
	writeln(keys, loopSize, encryption);	
}
