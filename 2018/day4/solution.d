#!/usr/bin/env -S rdmd -I..
module day4.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;

import common.io;
import std.regex;
import std.sumtype;

struct Record {
	string date;
	int endMin;
	int id;
	bool awake;
	int startMin;
	int duration;
}

alias Data = Record[];
Data parse(string fname) {
	string[] lines = readLines(fname);
	sort(lines);
	int id = -1;
	Record[] result;
	bool awake;
	int prevMin;

	foreach(string line; lines) {
		string date = line[6..11];
		int min = to!int(line[15..17]);
		string event = line[19..$];
		auto m = event.matchFirst(r"Guard #([0-9]+) begins shift");
		if (m) {
			id = to!int(m[1]);
			awake = true;
			prevMin = 0;
		}
		else if (event == "wakes up") {
			result ~= Record(date, min, id, awake, prevMin, min - prevMin);
			awake = true;
			prevMin = min;
		}
		else if (event == "falls asleep") {
			result ~= Record(date, min, id, awake, prevMin, min - prevMin);
			awake = false;
			prevMin = min;
		}
	}
	return result;
}

auto solve1(Data data) {
	// find guard that is asleep the most:
	int[int] asleepByGuard;
	int maxGuard = 0;
	int maxAsleep = 0;
	foreach(x; data) {
		if (!x.awake) {
			asleepByGuard[x.id] += x.duration;
			if (asleepByGuard[x.id] > maxAsleep) {
				maxGuard = x.id;
				maxAsleep = asleepByGuard[x.id];
			}
		}
	}

	// now find minute where guard x is asleep the most
	int[60] asleepByMinute;
	int maxAsleepByMinute = 0;
	int maxMinute = 0;
	foreach(x; data) {
		if (x.id == maxGuard && !x.awake) {
			foreach(i; x.startMin..x.endMin) {
				asleepByMinute[i]++;
				if (asleepByMinute[i] > maxAsleepByMinute) {
					maxAsleepByMinute = asleepByMinute[i];
					maxMinute = i;
				}
			}
		}
	}
	return maxGuard * maxMinute;
}

auto solve2(Data data) {
	int[int][int] asleepByGuardByMinute;
	int maxGuard = 0;
	int maxMinute = 0;
	int maxAsleep = 0;
	foreach(x; data) {
		if (!x.awake) {
			foreach(i; x.startMin..x.endMin) {
				asleepByGuardByMinute[x.id][i]++;
				if (asleepByGuardByMinute[x.id][i] > maxAsleep) {
					maxGuard = x.id;
					maxMinute = i;
					maxAsleep = asleepByGuardByMinute[x.id][i];
				}
			}
		}
	}
	return maxGuard * maxMinute;
}

void main(string[] args) {
	assert(args.length == 2, "This program requires an input file as argument");

	auto data = parse(args[1]);
	writeln(solve1(data)); // 50558
	writeln(solve2(data)); // 28198
}
