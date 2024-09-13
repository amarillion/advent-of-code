#!/usr/bin/env -S rdmd -I..
module day9.alt;

import std.stdio;
import std.string;
import std.conv;
import std.array;
import std.range;
import std.algorithm;

import common.io;

class Node(T) {
	Node next;
	Node prev;
	T payload;

	this(T _payload) {
		this.payload = _payload;
	}
}

/** 
 Simple circular doubly linked list, 
 couldn't figure out how to use std.container.dlist... 
*/
class DList(T) {
	Node!T start = null;

	Node!T front() {
		return start; 
	}

	/** remove element at the given position, and return the removed value */
	T removeAt(Node!T ptr) {
		auto prev = ptr.prev;
		auto next = ptr.next;
		prev.next = next;
		next.prev = prev;
		return ptr.payload;
	}

	/** insert a value at the very start of the list */
	Node!T insertFront(T value) {
		if (start is null) {
			start = new Node!T(value);
			start.next = start;
			start.prev = start;
		}
		else {
			start = insertAfter(start.prev, value);
		}
		return start;
	}

	/** insert a new element just after the given element */
	Node!T insertAfter(Node!T current, T value) {
		auto newNode = new Node!T(value);
		
		newNode.next = current.next;
		newNode.prev = current;
		current.next.prev = newNode;
		current.next = newNode;

		return newNode;
	}
}

/** walk along the dlist a given number of steps, steps may be positive (forward) or negative (backwards) */
Node!T walk(T)(Node!T current, int steps) {
	if (steps < 0) {
		foreach(i; 0..-steps) {
			current = current.prev;
		}
	}
	else {
		foreach(i; 0..steps) {
			current = current.next;
		}
	}
	return current;
}

struct Data {
	int numPlayers;
	int lastMarble;
}

Data parse(string fname) {
	string[] lines = readLines(fname);
	string[] fields = lines[0].split(" ");
	return Data(to!int(fields[0]), to!int(fields[6]));
}

auto solve(Data data) {
	auto q = new DList!int();
	q.insertFront(0);
	
	auto current = q.front;
	
	long[] players; players.length = data.numPlayers;

	foreach(int turn; 1 .. data.lastMarble + 1) {
		int next = turn;
		if (next % 23 == 0) {
			int player = (turn % data.numPlayers);
			players[player] += next;
			auto removalPos = current.walk(-7);
			current = removalPos.next;
			players[player] += q.removeAt(removalPos);
		}
		else {
			auto insertionPos = current.walk(+1);
			current = q.insertAfter(insertionPos, next);
		}

		// writeln("Turn: ", turn);
		// writeln("Queue: ");
		// auto s = q.start;
		// do {
		// 	write(s.payload, ", ");
		// 	s = s.next;
		// } while (s != q.start);
		// writeln();
	}

	return players.maxElement;
}

void main(string[] args) {
	assert(args.length == 2, "Expecting 1 argument: input file");
	auto data = parse(args[1]);
	writeln(solve(data));
	writeln(solve(Data(data.numPlayers, data.lastMarble * 100)));
}
