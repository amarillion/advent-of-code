#!/usr/bin/env -S rdmd -I..

import std.digest.md;
import std.stdio;
import std.conv;
import std.array;
import std.algorithm;

int findHashStartingWith(string input, string prefix, int start = 0) {
	int i = start;
	string hash;
	do {
		i++;
		MD5 md5;
		md5.start();
		string data = input ~ to!string(i);
		md5.put(cast(ubyte[])data);
		hash = toHexString(md5.finish()).dup;
	}
	while (!hash.startsWith(prefix));
	return i;
}

void main() {
	const input = "yzbqklnj";
	int answer1 = findHashStartingWith(input, "00000");
	int answer2 = findHashStartingWith(input, "000000", answer1);
	writeln("Answer:", [answer1, answer2]);
}