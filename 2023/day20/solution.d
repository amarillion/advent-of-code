#!/usr/bin/env -S rdmd -I..
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

	override Pulse[] sendPulse(string from, bool isHigh) {
		memory[from] = isHigh;
		bool allHigh = true;
		foreach(input; inputs) {
			if (!(input in memory && memory[input])) {
				allHigh = false;
				break;
			}
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
			writefln("%s -%s-> %s", pulse.src, pulse.isHigh ? "high": "low", pulse.dest);
			if (pulse.dest in data) {
				queue ~= data[pulse.dest].sendPulse(pulse.src, pulse.isHigh);
			}
			queue.popFront();
		}
	}
	writefln("%s * %s = %s", lowSent, highSent, lowSent * highSent);
	return lowSent * highSent;
}

auto solve2(Data data) {
	long buttonPresses = 0;
	bool rxLowSent = false;
	Pulse[] queue;
	while(!rxLowSent) {
		queue ~= Pulse("button", false, "broadcaster");
		buttonPresses++;
		while (!queue.empty) {
			auto pulse = queue.front;
			// writefln("%s -%s-> %s", pulse.src, pulse.isHigh ? "high": "low", pulse.dest);
			if (pulse.dest in data) {
				queue ~= data[pulse.dest].sendPulse(pulse.src, pulse.isHigh);
			}
			if (pulse.dest == "rx" && pulse.isHigh == false) {
				rxLowSent = true;
			}
			queue.popFront();
		}
	}
	return buttonPresses;
}

void main() {
	auto testData = parse("test-input");
	assert(solve1(testData) == 32000000, "Solution incorrect");

	auto testData2 = parse("test-input2");
	assert(solve1(testData2) == 11687500, "Solution incorrect");

	auto data = parse("input");
	auto result = solve1(data);
	assert(result == 812609846);
	writeln(result);

	data = parse("input");
	result = solve2(data);
	// assert(result == 812609846);
	writeln(result);

}
