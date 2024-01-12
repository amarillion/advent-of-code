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

class Rule {
	enum Type { CONDITION, ACCEPT, REJECT }
	Type type;

	// condition
	char left;
	char operator;
	int right;
	
	Rule ifTrue;
	Rule ifFalse;

	this(Type _type, char _left = '\0', char _operator = '\0', int _right = 0) {
		this.type = _type; 
		this.left = _left; 
		this.operator = _operator; 
		this.right = _right;
	}

	override string toString() const {
		return toString("");
	}

	string toString(string spacer) const {
		final switch(type) {
			case Type.ACCEPT: return "A";
			case Type.REJECT: return "R";
			case Type.CONDITION: return "%s %s %s\n%s ├true: %s\n%s └false: %s".format(
				left, operator, right, spacer, ifTrue.toString(spacer ~ " │"), spacer, ifFalse.toString(spacer ~ "  ")
			);
		}
	}
}

struct Part {
	int x;
	int m;
	int a;
	int s;
}

struct Data {
	Rule rootRule;
	Part[] parts;
}

Rule parseRule(const string[][string] rawRules, string workflowLabel) {
	if (workflowLabel == "A") {
		return new Rule(Rule.Type.ACCEPT);
	}
	else if (workflowLabel == "R") {
		return new Rule(Rule.Type.REJECT);
	}
	else {
		Rule result = null;
		Rule prev = null;
		foreach(ruleString; rawRules[workflowLabel]) {
			auto m2 = ruleString.matchFirst(regex(r"^([xmas])([><])(\d+):(\w+)$"));
			Rule current;
		
			if (!m2.empty) {
				current = new Rule(Rule.Type.CONDITION, m2[1][0], m2[2][0], to!int(m2[3]));
				current.ifTrue = parseRule(rawRules, m2[4]);
			}
			else {
				current = parseRule(rawRules, ruleString);
			}

			if (result is null) { result = current; }
			else { prev.ifFalse = current; }
			prev = current;
		}
		return result;
	}
}

Data parse(string fname) {
	string raw = readText(fname).stripRight;
	string[] parts = raw.split("\n\n");
	Data result;
	string[][string] rawRules;
	foreach(line; parts[0].split("\n")) {
		auto m = line.matchFirst(regex(r"^(\w+)\{(.*)\}$"));
		assert(!m.empty);
		string label = m[1];
		rawRules[label] = m[2].split(",");
	}

	result.rootRule = parseRule(rawRules, "in");
	foreach(line; parts[1].split("\n")) {
		auto m = line.matchFirst(regex(r"^\{x=(\d+),m=(\d+),a=(\d+),s=(\d+)\}$"));
		assert(!m.empty);
		result.parts ~= Part(to!int(m[1]), to!int(m[2]), to!int(m[3]), to!int(m[4]));
	}

	writeln(result.rootRule.toString());
	return result;
}

bool test(const Rule rule, Part part) {
	final switch(rule.type) {
		case Rule.Type.REJECT: return false;
		case Rule.Type.ACCEPT: return true;
		case Rule.Type.CONDITION: { 
			int value = 0;
			bool result = false;
			switch(rule.left) {
				case 'x': value = part.x; break;
				case 'm': value = part.m; break;
				case 'a': value = part.a; break;
				case 's': value = part.s; break;
				default: assert(false);
			}
			switch(rule.operator) {
				case '<': result = value < rule.right; break;
				case '>': result = value > rule.right; break;
				default: assert(false);
			}
			return result ? test(rule.ifTrue, part) : test(rule.ifFalse, part);
		}
	}
}

auto solve1(Data data) {
	long result = 0;
	foreach(part; data.parts) {
		write(part);
		bool testResult = test(data.rootRule, part);
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
		if (other.bottomIncl > topExcl || other.topExcl < bottomIncl) {
			topExcl = bottomIncl + 1;
		}
		else {
			bottomIncl = max(bottomIncl, other.bottomIncl);
			topExcl = min(topExcl, other.topExcl);
		}
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

long applyRange(const Rule rule, const PartRange partRange, int recursionLevel = 0) {
	PartRange current = partRange.dup;

	long result;
	final switch(rule.type) {
		case Rule.Type.REJECT: return 0;
		case Rule.Type.ACCEPT: return
			partRange.ranges['x'].total *
			partRange.ranges['m'].total *
			partRange.ranges['a'].total *
			partRange.ranges['s'].total;
		case Rule.Type.CONDITION: {
			result = 0;
			Range conditionFalse;
			Range conditionTrue;
			switch(rule.operator) {
				case '<': conditionTrue = Range(1, rule.right); conditionFalse = Range(rule.right, 4001); break;
				case '>': conditionFalse = Range(1, rule.right + 1); conditionTrue = Range(rule.right + 1, 4001);  break;
				default: assert(false);
			}
			PartRange forward = current.dup;
			forward.ranges[rule.left].intersect(conditionFalse);
			current.ranges[rule.left].intersect(conditionTrue);
			result += applyRange(rule.ifTrue, current, recursionLevel + 1);
			result += applyRange(rule.ifFalse, forward, recursionLevel + 1);
			return result;
		}
	}
}

long solve2(Data data) {
	auto partRange = new PartRange();
	long result = applyRange(data.rootRule, partRange);
	writeln(result);
	return result;
}

void main() {
	auto testData = parse("test-input");
	writeln(testData);
	assert(solve1(testData) == 19_114, "Solution incorrect");
	assert(solve2(testData) == 167_409_079_868_000, "Solution incorrect");
	
	auto data = parse("input");
	assert (solve1(data) == 376_008);
	long result = solve2(data);
	assert(result == 124_078_207_789_312); 
	writeln(result);
}
