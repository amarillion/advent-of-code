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

Node parse(string fname) {
	string[] lines = readLines(fname);
	int[] data = lines[0].split(" ").map!(to!int).array;
	return processNode(data);
}

class Node {
	Node[] children;
	int[] metaData;
}

int recursiveSum(Node n) {
	return n.metaData.sum + n.children.map!(c => recursiveSum(c)).sum;
}

int recursiveValue(Node n) {
	if (n.children.empty) { 
		return n.metaData.sum;
	}
	else {
		return n.metaData.map!(i => (i <= n.children.length ? n.children[i - 1].recursiveValue : 0)).sum;
	}
}

/*
 * Consume a chunk of `remain` and return it as a Node.
 * Recursive.
 */
Node processNode(ref int[] remain) {
	Node result = new Node();
	int numChildren = remain[0];
	int numMetaData = remain[1];
	remain = remain[2..$];
	foreach(i; 0..numChildren) {
		result.children ~= processNode(remain);
	}
	result.metaData = remain[0..numMetaData];
	remain = remain[numMetaData..$];
	return result;
}

void main(string[] args) {
	assert(args.length == 2, "Expecting 1 argument: input file");
	auto node = parse(args[1]);
	writeln(recursiveSum(node));
	writeln(recursiveValue(node));
}
