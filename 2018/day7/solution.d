#!/usr/bin/env -S rdmd -I..
module day7.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;
import std.regex;

import common.io;

alias Data = dchar[][dchar];
Data parse(string fname) {
	string[] lines = readLines(fname);
	Data data;
	foreach(line; lines) {
		auto result = line.matchFirst(r"Step (\w) must be finished before step (\w) can begin.");
		dchar before = result[1][0];
		dchar after = result[2][0];
		if (after !in data) {
			data[after] = [ before ];
		}
		else {
			data[after] ~= before;
		}
		// make sure all keys are in.
		if (before !in data) {
			data[before] = [];
		}
	}
	return data;
}

auto solve1(Data data) {
	dchar[] result;

	auto remain = data.dup;
	while (!remain.empty) {
		dchar[] available;
		foreach(dchar k, v; remain) {
			if (v.empty) {
				available ~= k;
			}
		}
		sort!"a < b"(available);
		dchar found = available[0];
		
		// remove found from both key and values.
		remain.remove(found);
		foreach(k, ref dchar[] v; remain) {
			v = to!(dchar[])(v.filter!(c => c != found).array); // Why is cast to dchar[] necessary? D trying to do funky business with utf8?
		}

		result ~= found;
	}
	return result;
}

class Worker {
	int timeRemain = 0;
	dchar job = '\0';
	bool free = true;
}

auto solve2(Data data, int numWorkers = 2, int workBaseCost = 0) {
	int second = 0;
	
	Worker[] workers;
	foreach (i; 0..numWorkers) { 
		workers ~= new Worker();
	}

	auto remain = data.dup;
	bool done = false;
	while (!done) {
			
		foreach(worker; workers) {
			if (!worker.free) {
				worker.timeRemain--;
				if (worker.timeRemain == 0) {
					worker.free = true;

					// clean job from system, new dependencies become available
					dchar found = worker.job;
					foreach(k, ref dchar[] v; remain) {
						v = to!(dchar[])(v.filter!(c => c != found).array); // Why is cast to dchar[] necessary? D trying to do funky business with utf8?
					}

				}
			}
		}

		foreach(worker; workers) {
			if (worker.free) {
				// find a job to do
				dchar[] available;
				foreach(dchar k, v; remain) {
					if (v.empty) {
						available ~= k;
					}
				}
				if (!available.empty) {
					sort!"a < b"(available);
					dchar found = available[0];
				
					// remove found from job list
					remain.remove(found);

					worker.free = false;
					worker.job = found;
					worker.timeRemain = found - 'A' + workBaseCost + 1;
				}
			}
		}

		// writef("%02d: ", second);
		// foreach(worker; workers) {
		// 	write(worker.free ? '.' : worker.job, "  ");
		// }	
		// writeln();
		
		second++;

		done = true;
		foreach(worker; workers) {
			if (!worker.free) { done = false; break; }
		}
	}

	return second-1;
}


void main(string[] args) {
	assert(args.length == 2, "Expecting 1 argument: input file");
	
	auto data = parse(args[1]);
	writeln(solve1(data));

	if (args[1].startsWith("test")) {
		writeln(solve2(data)); // <- test input
	}
	else {
		writeln(solve2(data, 5, 60)); // input
	}
}