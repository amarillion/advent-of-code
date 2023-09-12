#!/usr/bin/env rdmd
import std.stdio;
import std.string;
import std.conv;

void main()
{
	int[] data = [];

	File file = File("input", "rt");
	while (!file.eof()) {
		string line = chomp(file.readln()); 
		if (line.length == 0) break;
		foreach (string field; line.split(",")) {
			int i = to!int(field);
			data ~= [ i ];
		}
	}

	int[int] lastSpoken;

	int round = 1;
	for (int i = 0; i < data.length - 1; ++i) {
		lastSpoken[data[i]] = round;
		round++;
	}

	round++;
	int prev = data[data.length-1];

	writeln(data, lastSpoken);

	while (round <= 30_000_000) {
		
		int number;
		if (prev in lastSpoken) {
			number = (round - 1 - lastSpoken[prev]);
		}
		else {
			number =  0;
		}

		if (round % 1_000_000 == 0) {
			writeln("Round: ", round, " - Number: ", number);
		}

		lastSpoken[prev] = round-1;
		prev = number;
		round++;
	}

}
