#!/usr/bin/env rdmd

import std.stdio;
import std.string;
import std.conv;
import std.algorithm;
import std.array;

struct Rule {
	bool isLiteral;
	bool isBinary;
	int[] left;
	int[] orRight;
	char literal = ' ';
}

Rule[int] rules;

void parse(string[] rawRules) {
	
	int[] splitNumbers(string str) {
		return str.split(' ').map!(to!int).array();
	}

	foreach (raw; rawRules) {
		Rule rule;
		string[] fields = raw.split(": ");
		int idx = to!int(fields[0]);
		if (fields[1].indexOf('|') >= 0) {
			rule.isBinary = true;
			string[] parts = fields[1].split(" | ");
			rule.left = splitNumbers(parts[0]);
			rule.orRight = splitNumbers(parts[1]);
		}
		else if (fields[1].indexOf('"') >= 0) {
			rule.isLiteral = true;
			rule.literal = fields[1][1];
		}
		else {
			rule.left = splitNumbers(fields[1]);
		}
		rules[idx] = rule;
	}
}

int[] matchRules(string input, int[] ruleIds, int pos) {
	int[] cur = [ pos ];
	foreach(ruleId; ruleIds) {
		int[] next = [];
		foreach(c; cur) {
			next ~= matches(input, ruleId, c);
		}
		cur = next;
		if (cur.empty) break;
	}
	return cur;
}

int[] matches(string input, int ruleId, int pos) {
	
	Rule rule = rules[ruleId];
	
	if (pos >= input.length) {
		return [];
	}

	if (rule.isLiteral) {
		bool hit = rule.literal == input[pos];
		return hit ? [ pos + 1 ] : [];
	}
	else {
		int alt = pos;
		int[] result;
		result ~= matchRules (input, rule.left, pos);
		if (rule.isBinary) {
			result ~= matchRules (input, rule.orRight, alt);
		}
		return result;
	}
}

string[] readParagraph(File file) {
	string[] result = [];
	while (!file.eof()) {
		string line = chomp(file.readln()); 
		if (line.length == 0) break;
		result = result ~ line;
	}
	return result;
}

string[] readLines(string fname) {
	File file = File(fname, "rt");
	string[] result = [];
	while (!file.eof()) {
		string line = chomp(file.readln()); 
		result = result ~ line;
	}
	// Remove empty line...
	if (result[$-1].length == 0) { result = result[0..$-1]; }
	return result;
}

long countMatches(string[] lines) {
	long sum = 0;
	foreach (line; lines) {
		int[] result = matches(line, 0, 0);
		if (result.canFind(line.length)) {
			sum++;
		}
	}
	return sum;
}

void main()
{
	File file = File("input", "rt");
	string[] rawRules = readParagraph(file);
	string[] lines = readParagraph(file);	
	parse(rawRules);
	
	writeln("Part 1: ", countMatches(lines));

	// part2: insert extra rules;
	Rule rule8;
	rule8.isBinary = true;
	rule8.left = [42];
	rule8.orRight = [42, 8];
	Rule rule11;
	rule11.isBinary = true;
	rule11.left = [42, 31];
	rule11.orRight = [42, 11, 31];
	rules[8] = rule8;
	rules[11] = rule11;

	writeln("Part 2: ", countMatches(lines));

}
