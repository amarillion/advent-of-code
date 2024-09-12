#!/usr/bin/env -S rdmd -I..
module day8.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;

import common.io;
import core.stdcpp.array;

alias Data = int[];
Data parse(string fname) {
	string[] lines = readLines(fname);
	return lines[0].split(" ").map!(to!int).array;
}


class Node {
	Node[] children;
	int[] metaData;

	string repr(string indent = "") {
		return indent 
			~ to!string(metaData) ~ "\n" 
			~ children.map!(c => c.repr(indent ~ " ")).join("");
	}

	int sum() {
		return metaData.sum + children.map!(c => c.sum).sum;
	}

}

class Parser {
	this(Data data) {
		remain = data.dup;
	}
	
	Data remain;

	Node parseNode() {
		Node result = new Node();
		int numChildren = remain[0];
		int numMetaData = remain[1];
		remain = remain[2..$];
		foreach(i; 0..numChildren) {
			result.children ~= parseNode();
		}
		result.metaData = remain[0..numMetaData];
		remain = remain[numMetaData..$];
		return result;
	}
}

auto solve1(Data data) {
	// recursive descent parser...
	auto parser = new Parser(data);
	Node node = parser.parseNode();
	writeln(node.repr(""));
	writeln(data);
	return node.sum;
}

void main(string[] args) {
	assert(args.length == 2, "Expecting 1 argument: input file");
	auto data = parse(args[1]);
	writeln(solve1(data));
}
