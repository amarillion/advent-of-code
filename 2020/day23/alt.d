#!/usr/bin/env -S rdmd -I..

import common.io;
import std.stdio;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.format : formattedRead;
import std.exception;
import std.range;
import std.container : DList;

enum part1 = false;

//TODO: why is this not in standard library?
int indexOf(int[] array, int needle) {
	foreach(i, a; array) {
		if (a == needle) {
			return cast(int)i;
		}
	}
	return -1;
}

int max(int[] array) {
	int m = array[0];
	foreach(i; array[1..$]) {
		if (i > m) {
			m = i;
		}
	}
	return m;
}

class Node {

	this(int val) {
		this.val = val;
	}
	int val;
	Node next = null;
}

struct OrderedMap {
	private Node first = null;
	private Node last = null;
	private Node [int] searchIdx;
	size_t length; // NOTE: initalized, never updated

	this(int[] data) {
		foreach (val; data) {
			pushBack(val);
		}
		length = data.length;
	}

	void pushBack(int val) {
		auto node = new Node(val);
		searchIdx[val] = node;
		if (last is null) {
			assert(first is null);
			first = node;
			last = node;
		}
		else {
			auto temp = last;
			assert(temp.next is null);
			// node.prev = temp;
			temp.next = node;
			last = node;
		}
	}

	int unshift() {
		assert(first !is null);
		assert(last !is null);
		auto temp = first;
		searchIdx.remove(temp.val);
		first = temp.next;
		return temp.val;
	}

	Node insertAfter(Node before, int val) {
		assert(first !is null);
		assert(last !is null);
		auto node = new Node(val);
		searchIdx[val] = node;
		auto after = before.next;
		before.next = node;
		node.next = after;
		if (last == before) {
			last = node;
		}
		return node;
	}

	Node find(int needle) {
		if (needle in searchIdx) {
			return searchIdx[needle];
		}
		return null;
	}

	int[] toArray() {
		int[] result;
		for(Node n = first; n !is null; n = n.next) {
			result ~= n.val;
		}
		return result;
	}
}

unittest {
	auto cups = OrderedMap();
	
	cups.pushBack(1);
	cups.pushBack(4);
	cups.pushBack(9);
	assert(cups.toArray == [1, 4, 9]);
	
	Node mid = cups.find(4);
	mid.val = 5;
	assert(cups.toArray == [1, 5, 9]);
	
	cups.insertAfter(mid, 7);
	assert(cups.toArray == [1, 5, 7, 9]);

	assert(cups.last.next is null);
	cups.insertAfter(cups.last, 12);
	assert(cups.toArray == [1, 5, 7, 9, 12]);
	assert(cups.last.next is null);

	int val = cups.unshift();
	assert(val == 1);
	assert(cups.toArray == [5, 7, 9, 12]);
}


alias Cups = OrderedMap;

void playRound(ref Cups cups, int move, bool log = false) {
	// NB: cups is always arranged so that pos is first.
	if (log) {
		writefln("-- Move %s --", move+1);
		foreach(i, cup; cups.toArray()) {
			writef(i == 0 ? "(%s) " : "%s ", cup);
		}
		writeln();
	}

	// take 3 out
	int first = cups.unshift();
	int[] taken = [
		cups.unshift(),
		cups.unshift(),
		cups.unshift()
	];
	
	if (log) writeln("pick up: ", taken);

	// select destination.
	int destVal = first;
	do {
		destVal -= 1;
		if (destVal <= 0) destVal += cups.length;
	} while (taken.indexOf(destVal) >= 0);
	
	if (log) writeln("Destination: ", destVal);
	Node destNode = cups.find(destVal);
	
	// now re-shuffle
	
	Node node = destNode;
	node = cups.insertAfter(node, taken[0]);
	node = cups.insertAfter(node, taken[1]);
	node = cups.insertAfter(node, taken[2]);
	cups.pushBack(first);

}

int[] part1result (ref Cups cups) {
	auto data = cups.toArray();
	size_t split = data.indexOf(1);
	return data[split+1..$] ~ data[0..split];
}

unittest {
	// test case
	auto cups = Cups([3, 8, 9, 1, 2, 5, 4, 6, 7]);
	foreach (round; 0..100) {
		playRound(cups, round);
	}
	assert(cups.part1result == [6, 7, 3, 8, 4, 5, 2, 9]);

	// input case
	cups = Cups([4, 6, 3, 5, 2, 8, 1, 7, 9]);
	foreach (round; 0..100) {
		playRound(cups, round);
	}
	assert(cups.part1result == [5, 2, 9, 3, 7, 8, 4, 6]);
}

void main() {
	
	enum ROUNDS = part1 ? 100 : 10_000_000;
	bool FILL = !part1;
	
	int[] data = readLines("input")[0].map!(ch => to!int(ch - '0')).array;
	
	if (FILL) {
		int i = cast(int)data.length;
		int p = data.max() + 1;
		data.length = 1_000_000;
		for(; i < data.length; ++i, ++p) {
			data[i] = p;
		}
	}

	auto cups = Cups(data);
	foreach (round; 0 .. ROUNDS) {
		playRound(cups, round, part1);

		if (round % 1000 == 0) {
			if (round % 20_000 == 0) {
				cups.searchIdx.rehash;
				writeln();
				writeln(round);
			}
			write('.');
			stdout.flush();
		}		

	}

	writeln("Final result:");

	if (part1) {
		// part 1
		int[] output = part1result(cups);
		writeln(format("%(%s%)", output));
	}
	else {
		// part 2
		Node split = cups.find(1);
		Node n1 = split.next;
		Node n2 = split.next.next;
		assert(split.val == 1);
		writeln(n1.val, " * ", n2.val, " = ", cast(long)n1.val * cast(long)n2.val);
	}
}
