#!/usr/bin/env -S rdmd -I..
module day19.solution;

import std.file;
import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;
import std.regex;

import common.io;

struct Rule {
	bool hasCondition;
	string left;
	string operator;
	int right;
	string dest;
}

struct Part {
	int x;
	int m;
	int a;
	int s;
}

struct Data {
	Rule[][string] workflows;
	Part[] parts;
}

Data parse(string fname) {
	string raw = readText(fname).stripRight;
	string[] parts = raw.split("\n\n");
	Data result;
	foreach(line; parts[0].split("\n")) {
		auto m = line.matchFirst(regex(r"^(\w+)\{(.*)\}$"));
		assert(!m.empty);
		string label = m[1];
		Rule[] rules = [];
		
		foreach(ruleString; m[2].split(",")) {
			auto m2 = ruleString.matchFirst(regex(r"^([xmas])([><])(\d+):(\w+)$"));
			if (!m2.empty) {
				rules ~= Rule(true, m2[1], m2[2], to!int(m2[3]), m2[4]);
			}
			else {
				rules ~= Rule(false, "", "", 0, ruleString);
			}
		}
		result.workflows[label] = rules;
	}
	foreach(line; parts[1].split("\n")) {
		auto m = line.matchFirst(regex(r"^\{x=(\d+),m=(\d+),a=(\d+),s=(\d+)\}$"));
		assert(!m.empty);
		result.parts ~= Part(to!int(m[1]), to!int(m[2]), to!int(m[3]), to!int(m[4]));
	}
	return result;
}

bool test(const Data data, Part part, string workflowLabel) {
	writef(" -> %s", workflowLabel);
	
	if (workflowLabel == "R") {
		return false;
	}
	else if (workflowLabel == "A") {
		return true;
	}

	foreach(rule; data.workflows[workflowLabel]) {
		if (rule.hasCondition) {
			int value = 0;
			bool result = false;
			switch(rule.left[0]) {
				case 'x': value = part.x; break;
				case 'm': value = part.m; break;
				case 'a': value = part.a; break;
				case 's': value = part.s; break;
				default: assert(false);
			}
			switch(rule.operator[0]) {
				case '<': result = value < rule.right; break;
				case '>': result = value > rule.right; break;
				default: assert(false);
			}
			if (result) {
				return test(data, part, rule.dest);
			}
		}
		else {
			return test(data, part, rule.dest);
		}
	}
	assert(false); // last rule is always unconditional... 
}

auto solve1(Data data) {
	long result = 0;
	foreach(part; data.parts) {
		write(part);
		bool testResult = test(data, part, "in");
		writeln(" ", testResult);
		if (testResult) {
			result += part.x + part.m + part.a + part.s;
		}
	}
	return result;
}

void main() {
	auto testData = parse("test-input");
	writeln(testData);
	assert(solve1(testData) == 19_114, "Solution incorrect");

	auto data = parse("input");
	auto result = solve1(data);
	// assert(result == 1);
	writeln(result);
}
