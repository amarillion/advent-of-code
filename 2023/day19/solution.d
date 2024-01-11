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

struct Range {
	int bottomIncl;
	int topExcl;

	@property long total() const {
		return topExcl - bottomIncl;
	}

	void intersect(Range other) {
		bottomIncl = max(bottomIncl, other.bottomIncl);
		topExcl = min(topExcl, other.topExcl);
		assert (topExcl >= bottomIncl);
	}
}

class PartRange {
	Range[char] ranges;
	this() {
		ranges['x'] = Range(1, 4001);
		ranges['m'] = Range(1, 4001);
		ranges['a'] = Range(1, 4001);
		ranges['s'] = Range(1, 4001);
	}
	
	this(const PartRange self) {
		foreach(key, value; self.ranges) {
			ranges[key] = value;
		}
	}

	@property PartRange dup() const {
		return new PartRange(this);
	}

	override string toString() const {
		return "x:%s-%s,m:%s-%s,a:%s-%s,s:%s-%s".format(
			ranges['x'].bottomIncl, ranges['x'].topExcl,
			ranges['m'].bottomIncl, ranges['m'].topExcl,
			ranges['a'].bottomIncl, ranges['a'].topExcl,
			ranges['s'].bottomIncl, ranges['s'].topExcl,
		);
	}
}

long applyRange(const Data data, const PartRange partRange, string workflowLabel, int recursionLevel = 0) {
	PartRange current = partRange.dup;

	long result;
	if (workflowLabel == "R") {
		result = 0;
	}
	else if (workflowLabel == "A") {
		result = 
			partRange.ranges['x'].total *
			partRange.ranges['m'].total *
			partRange.ranges['a'].total *
			partRange.ranges['s'].total;
	}
	else {
		result = 0;
		foreach(rule; data.workflows[workflowLabel]) {
			if (rule.hasCondition) {
				Range conditionFalse;
				Range conditionTrue;
				switch(rule.operator[0]) {
					case '<': conditionTrue = Range(1, rule.right); conditionFalse = Range(rule.right, 4001); break;
					case '>': conditionFalse = Range(1, rule.right); conditionTrue = Range(rule.right, 4001);  break;
					default: assert(false);
				}
				PartRange forward = current.dup;
				forward.ranges[rule.left[0]].intersect(conditionTrue);
				current.ranges[rule.left[0]].intersect(conditionFalse);
				result += applyRange(data, forward, rule.dest, recursionLevel + 1);
			}
			else {
				result += applyRange(data, current, rule.dest, recursionLevel + 1);
			}
		}
	}
	writefln("%sWorkflow %s returning %s for part %s", ' '.repeat(recursionLevel), workflowLabel, result, partRange);
	return result;
}

long solve2(Data data) {
	auto partRange = new PartRange();
	long result = applyRange(data, partRange, "in");
	return result;
}

void main() {
	auto testData = parse("test-input");
	writeln(testData);
	assert(solve1(testData) == 19_114, "Solution incorrect");
	writeln(solve2(testData));
	assert(solve2(testData) == 167_409_079_868_000, "Solution incorrect");
	auto data = parse("input");
	assert (solve1(data) == 376_008);
	long result = solve2(data);
	// assert(result == 1); 
	// First answer 124078347779837 too high...
	writeln(result);
}
