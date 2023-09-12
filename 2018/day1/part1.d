#!/usr/bin/env -S rdmd -I..

import std.stdio;
import std.string;
import std.conv;

void main() {

	long sum = 0;
	string line;
    while ((line = readln()) !is null) {
		// extract sign
		line = chomp(line);
		const sign = line[0];
		const value = to!long(line[1..$]);
		switch(sign) {
			case '+': sum += value; break;
			case '-': sum -= value; break;
			default: assert(false);
		}
	}
	writeln("Final result:");
	writeln(sum);
}
