#!/usr/bin/env -S rdmd -I..
module day25.solution;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;
import std.random;

import common.io;
import common.bfs;
import common.pairwise;

alias Graph = string[][string];

Graph parse(string fname) {
	string[] lines = readLines(fname);
	Graph result;
	foreach(line; lines) {
		string[] fields = line.split(": ");
		string key = fields[0];
		string[] nodes = fields[1].split(" ");
		result[key] = nodes;
	}

	return result;
}


auto solve1(Graph graph) {

	// make graph bidirectional... AFTER creating edgeList...
	foreach(src, dests; graph) {
		foreach(dest; dests) {
			graph[dest] ~= src;
		}
	}

	string origin = graph.keys.front;

	int[string] frqMap;

	// try lots of times
	foreach(k; 1..1000) {
		// pick random edge
		string src = choice(graph.keys);
		string dest = choice(graph.keys);

		// find path between edges
		auto bfsResult = bfs!string(
			src,
			(n, i) => n == dest,
			n => graph[n]
		);

		string current = dest;
		string[] path = [ dest ];
		while (current != src) {
			current = bfsResult.prev[current];
			path ~= current;
		}

		// do frequency count on edges
		for(int i = 1; i < path.length; ++i) {
			string edge = path[i] < path[i-1] ? path[i-1] ~ "-" ~ path[i] : path[i] ~ "-" ~ path[i-1];
			if(edge !in frqMap) frqMap[edge] = 0;
			frqMap[edge]++; 
		}
	}

	string[] sortedKeys = frqMap.keys;
	sort!((string a, string b) => frqMap[a] > frqMap[b])(sortedKeys);
	// foreach(string key; sortedKeys[0..min($,100)]) {
	// 	writefln("%s: %s", key, frqMap[key]);
	// }
	
	// assumption: most frequently used edges are most likely to be part of minimal cut set.
	// try all combinations of top 10.
	string[][] edgeList;
	foreach(edge; sortedKeys[0..10]) {
		edgeList ~= edge.split("-");
	}

	// // TODO:
	// // foreach(triplet; tripletwise(edgeList)) {

	long count = 0;
	// try each triple of three edges
	for(int i = 0; i < edgeList.length; ++i) {
		for (int j = 0; j < i; ++j) {
			for (int k = 0; k < j; ++k) {
				// use bfs to see if all nodes are reachable
				
				// adjacency function excludes three selected edges
				string[] adjacencyFunc(string node) {
					string dest = "";
					if (node == edgeList[i][0]) { dest = edgeList[i][1]; }
					if (node == edgeList[j][0]) { dest = edgeList[j][1]; }
					if (node == edgeList[k][0]) { dest = edgeList[k][1]; }
					if (node == edgeList[i][1]) { dest = edgeList[i][0]; }
					if (node == edgeList[j][1]) { dest = edgeList[j][0]; }
					if (node == edgeList[k][1]) { dest = edgeList[k][0]; }
					return graph[node].filter!(l => l != dest).array;
				}

				// check how many nodes are reachable.
				auto data = bfs!string(
					origin, 
					(string n, int i) => false, 
					(string n) => adjacencyFunc(n));
				// writeln(data.dist.length);
				if (data.dist.length < graph.length) {
					return data.dist.length * (graph.length - data.dist.length);
				}

				count++;
				if (count % 1000 == 0) writeln(count); 
				// running... 700 million possibilities...
			}
		}
	}
	

	return 0;
}

void main(string[] args) {
	assert(args.length == 2, "Expected one argument: input file");
	
	auto data = parse(args[1]);
	writeln(solve1(data));
}

// auto testData = parse("test-input");
// 	assert(solve1(testData) == 54, "Solution incorrect");

// 	auto data = parse("input");
// 	auto result = solve1(data);
// 	assert(result == 525264);
// 	writeln(result);