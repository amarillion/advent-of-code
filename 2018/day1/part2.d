#!/usr/bin/env -S rdmd -I..

import std.stdio;
import std.string;
import std.conv;

void main() {

	string line;
    long[] vals;
	while ((line = readln()) !is null) {
		// extract sign
		line = chomp(line);
		const sign = line[0];
		const value = to!long(line[1..$]);
		switch(sign) {
			case '+': vals ~= value; break;
			case '-': vals ~= -value; break;
			default: assert(false);
		}
	}

	bool[long] reached;
	
	bool found = false;
	long frq = 0;
	while(!found) {
		foreach(val; vals) {
			frq += val;
			if (frq in reached) {
				found = true;
				break;
			}
			reached[frq] = true;
		}
	}

	writeln("Final result:");
	writeln(frq);
}
