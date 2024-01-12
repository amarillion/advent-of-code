#!/usr/bin/env -S rdmd -I..
module day19.solutionVisitorPattern;

import std.file;
import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;
import std.regex;

import common.io;

interface RuleVisitor(T, P) {
	T visitAccept(P context);
	T visitReject(P context);
	T visitCondition(P context, char left, char operator, int right, Rule ifTrue, Rule ifFalse);
}

interface Rule {
	T accept(T,P)(P context, RuleVisitor!(T, P) visitor);
}

class AcceptRule : Rule {
	override T accept(T,P)(P context, RuleVisitor!(T, P) visitor) { return visitor.visitAccept(context); }
}

class RejectRule : Rule {
	override T accept(T,P)(P context, RuleVisitor!(T, P) visitor) { return visitor.visitReject(context); }
}

class ConditionRule : Rule {
	char left;
	char operator;
	int right;
	
	Rule ifTrue;
	Rule ifFalse;

	this(char _left, char _operator, int _right) {
		this.left = _left; 
		this.operator = _operator; 
		this.right = _right;
	}

	override T accept(T,P)(P context, RuleVisitor!(T, P) visitor) { 
		return visitor.visitCondition(context, left, operator, right, ifTrue, ifFalse); 
	}
}

class FormattedStringVisitor : RuleVisitor!(string, string) {

	override string visitAccept(string spacer) { return "A"; }
	override string visitReject(string spacer) { return "R"; }
	
	override string visitCondition(string spacer, char left, char operator, int right, Rule ifTrue, Rule ifFalse) {
		string spacerTrue = spacer ~ " │";
		string spacerFalse = spacer ~ "  ";
		return "%s %s %s\n%s ├true: %s\n%s └false: %s".format(
			left, operator, right, spacer, 
			ifTrue.accept!(string, string)(spacerTrue, this), 
			spacer, 
			ifFalse.accept!(string, string)(spacerFalse, this)
		);
	}

	static ruleToString(Rule root) {
		auto visitor = new FormattedStringVisitor();
		return root.accept!(string, string)("", visitor);
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
		return new AcceptRule();
	}
	else if (workflowLabel == "R") {
		return new RejectRule();
	}
	else {
		ConditionRule[] chain;
		foreach(ruleString; rawRules[workflowLabel]) {
			auto m2 = ruleString.matchFirst(regex(r"^([xmas])([><])(\d+):(\w+)$"));
			if (!m2.empty) {
				auto current = new ConditionRule(m2[1][0], m2[2][0], to!int(m2[3]));
				current.ifTrue = parseRule(rawRules, m2[4]);
				if (!chain.empty) { chain[$].ifFalse = current; }
				chain ~= current;
			}
			else {
				chain[$].ifFalse = parseRule(rawRules, ruleString);
			}
		}
		return chain[0];
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

	writeln(FormattedStringVisitor.ruleToString(result.rootRule));
	return result;
}

class TestVisitor : RuleVisitor!(bool, const Part) {
	override bool visitAccept(const Part part) { return true; }
	override bool visitReject(const Part part) { return false; }
	override bool visitCondition(const Part part, char left, char operator, int right, Rule ifTrue, Rule ifFalse) {
		int value = 0;
		switch(left) {
			case 'x': value = part.x; break;
			case 'm': value = part.m; break;
			case 'a': value = part.a; break;
			case 's': value = part.s; break;
			default: assert(false);
		}
		bool result = false;
		switch(operator) {
			case '<': result = value < right; break;
			case '>': result = value > right; break;
			default: assert(false);
		}
		return result 
			? ifTrue.accept!(bool, const Part)(part, this) 
			: ifFalse.accept!(bool, const Part)(part, this);
	}
}

auto solve1(Data data) {
	long result = 0;
	foreach(part; data.parts) {
		write(part);
		bool testResult = data.rootRule.accept!(bool, const Part)(part, new TestVisitor());
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

class RangeVisitor : RuleVisitor!(long, PartRange) {
	override long visitAccept(PartRange partRange) {
		return
			partRange.ranges['x'].total *
			partRange.ranges['m'].total *
			partRange.ranges['a'].total *
			partRange.ranges['s'].total;
	}
	override long visitReject(PartRange partRange) {
		return 0;
	}
	override long visitCondition(PartRange partRange, char left, char operator, int right, Rule ifTrue, Rule ifFalse) {
		long result = 0;
		Range conditionFalse;
		Range conditionTrue;
		switch(operator) {
			case '<': conditionTrue = Range(1, right); conditionFalse = Range(right, 4001); break;
			case '>': conditionFalse = Range(1, right + 1); conditionTrue = Range(right + 1, 4001);  break;
			default: assert(false);
		}
		PartRange current = partRange.dup;
		PartRange forward = current.dup;
		forward.ranges[left].intersect(conditionFalse);
		current.ranges[left].intersect(conditionTrue);
		result += ifTrue.accept!(long, PartRange)(current, this);
		result += ifFalse.accept!(long, PartRange)(forward, this);
		return result;
	}
}

long solve2(Data data) {
	auto partRange = new PartRange();
	long result = data.rootRule.accept!(long, PartRange)(partRange, new RangeVisitor());
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
