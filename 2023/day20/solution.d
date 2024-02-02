#!/usr/bin/env -S rdmd -I.. -O
module day20.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;

import common.io;

struct Pulse {
	string src;
	bool isHigh;
	string dest;
}

abstract class Module {
	static long buttonCounter = 0;
	long delta = 0;
	string name;
	string[] inputs = [];
	string[] outputs = [];
	Pulse[] dispatch(bool isHigh) {
		Pulse[] result;
		foreach(output; outputs) {
			result ~= Pulse(name, isHigh, output); 
		}
		return result;
	}
	Pulse[] sendPulse(string from, bool isHigh);
	this(string _name) { this.name = _name; }
}

class Broadcast : Module {
	this(string _name) { super(_name); }
	override Pulse[] sendPulse(string from, bool isHigh) {
		buttonCounter++;
		return dispatch(isHigh);
	}
}
class FlipFlop : Module {
	this(string _name) { super(_name); }
	bool state = false;
	override Pulse[] sendPulse(string from, bool isHigh) {
		Pulse[] result;
		if (!isHigh) {
			state = !state;
			result ~= dispatch(state);
		}
		return result;
	}
}
class Conjunction : Module {
	this(string _name) { super(_name); }
	bool[string] memory;
	long prev = 0;

	override Pulse[] sendPulse(string from, bool isHigh) {
		memory[from] = isHigh;
		bool allHigh = true;
		foreach(input; inputs) {
			if (!(input in memory && memory[input])) {
				allHigh = false;
				break;
			}
		}
		if (allHigh) {
			delta = (buttonCounter - prev);
			prev = buttonCounter;
		}
		return dispatch(!allHigh);
	}
}

alias Data = Module[string];
Data parse(string fname) {
	string[] lines = readLines(fname);
	string[][string] rawOutputs;

	Data result;
	foreach(line; lines) {
		string[] fields = line.split(" -> ");
		string label = fields[0] == "broadcaster" ? fields[0] : fields[0][1..$];
		string[] outputs = fields[1].split(", ");
		rawOutputs[label] = outputs;
		Module mod = null;
		if (fields[0] == "broadcaster") {
			mod = new Broadcast(label);
		}
		else if (fields[0][0] == '%') {
			mod = new FlipFlop(label);
		}
		else if (fields[0][0] == '&') {
			mod = new Conjunction(label);
		}
		else {
			assert(false);
		}
		result[label] = mod;
	}
	// initialize inputs
	foreach(from, outputs; rawOutputs) {
		result[from].outputs = outputs;
		foreach(to; outputs) {
			// writefln("[%s] [%s]", from, to);
			if (to in result) {
				result[to].inputs ~= from;
			}
		}
	}

	return result;
}

auto solve1(Data data) {
	long highSent = 0;
	long lowSent = 0;

	Pulse[] queue;
	foreach(i; 0..1000) {
		queue ~= Pulse("button", false, "broadcaster");
		while (!queue.empty) {
			auto pulse = queue.front;
			if (pulse.isHigh) { highSent++; } else { lowSent++; }
			// writefln("%s -%s-> %s", pulse.src, pulse.isHigh ? "high": "low", pulse.dest);
			if (pulse.dest in data) {
				queue ~= data[pulse.dest].sendPulse(pulse.src, pulse.isHigh);
			}
			queue.popFront();
		}
	}
	// writefln("%s * %s = %s", lowSent, highSent, lowSent * highSent);
	return lowSent * highSent;
}

auto solve2(Data data) {
	Pulse[] queue;
	foreach(i; 0..20_000) {
		queue ~= Pulse("button", false, "broadcaster");
		while (!queue.empty) {
			auto pulse = queue.front;
			// writefln("%s -%s-> %s", pulse.src, pulse.isHigh ? "high": "low", pulse.dest);
			if (pulse.dest in data) {
				queue ~= data[pulse.dest].sendPulse(pulse.src, pulse.isHigh);
			}
			queue.popFront();
		}
	}

	// through analysis of the network, we find that four 
	// conjunction modules are recurring periodically, and that the period is a prime number around ~ 4000.
	// As a guess, if we multiply the four prime numbers, do we get our answer?
	// apparently, yes!
	long result = 1;
	foreach(mod; data.values) {
		if (mod.delta > 1000) {
			result *= mod.delta;
		}
	}
	return result;
}

void main(string[] args) {
	assert(args.length == 2, "Expected one argument: input file");

	auto data = parse(args[1]);
	writeln(solve1(data));

	auto data2 = parse(args[1]);
	writeln(solve2(data2));
}
