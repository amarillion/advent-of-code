#!/usr/bin/env tsx

import { readFileSync } from "fs";
import { assert } from "../common/assert.js";

/*



NOTE: is there any similarity to the problem of 2022, day 19?

 */

class Node {
	id: string;
	rate: number;
	exits: string[];
}

class Network {
	max: number = 0;
	nodes: { [key: string]: Node } = {}
};

function parse(fname: string) {
	let raw = readFileSync(fname).toString('utf-8');
	let lines = raw.split('\n');

	const result = new Network();
	for (const line of lines) {
		if (line === "") continue;
		const matcher = line.match(/Valve (?<id>\w+) has flow rate=(?<rate>\d+); tunnels? leads? to valves? (?<exits>.*)/);
		assert(Boolean(matcher), `Couldn't parse [${line}]`);
		const { id, rate, exits } = matcher.groups;
		result.nodes[id] = {
			id,
			rate: +rate,
			exits: exits.split(", ")
		};
		console.log(id, +rate, result.nodes[id].exits);
	}

	result.max = Object.values(result.nodes).map(n => n.rate).reduce((prev, curr) => prev + curr, 0);
	console.log(result.max);

	return result;
}

class State {
	minute = 1;
	open = new Set<string>();
	position = "AA";
	elephant = "AA";
	rate = 0;
	total = 0;
	// theoretical = 0;

	copy() {
		const result = new State();
		result.minute = this.minute;
		result.open = new Set<string>(this.open);
		result.position = this.position;
		result.total = this.total;
		result.rate = this.rate;
		result.elephant = this.elephant;
		return result;
	}
}

function advance(n: Network, s: State) {
	s.minute++;
	s.rate = [...s.open].map(valve => n.nodes[valve].rate).reduce((a, b) => a + b, 0);
	s.total += s.rate;
	// s.theoretical = s.total + ((30 - s.minute) * n.max);

	// console.log(`Min: ${s.minute}, You: ${s.position} Elephant: ${s.elephant}, rate: ${s.rate}`)
}

function shouldOpen(n: Network, s: State, id: string) {
	return (!s.open.has(id)) && n.nodes[id].rate > 0;
}

function *possibleMoves(n: Network, s: State) {
	/*
	simulation:
	1. open valve (if not open, if non-zero)
	2. move to exit
	*/

	if (s.rate === n.max) {
		// no further moves necessary
		yield s.copy();
		return;
	}

	if (shouldOpen(n, s, s.position)) {
		const move = s.copy();
		move.open.add(s.position);
		yield move;
	}
	for (const exit of n.nodes[s.position].exits) {
		const move = s.copy();
		move.position = exit;
		yield move;
	}
}

function *possibleMoves2(n: Network, s: State) {
	/**
	 * Wrap generator of player moves with generator of all possible elephant moves
	 */
	if (s.rate === n.max) {
		// no further moves necessary
		yield s.copy();
		return;
	}

	if (shouldOpen(n, s, s.elephant)) {
		const move = s.copy();
		move.open.add(s.elephant);
		yield *possibleMoves(n, move);
	}
	for (const exit of n.nodes[s.elephant].exits) {
		const move = s.copy();
		move.elephant = exit;
		yield *possibleMoves(n, move);
	}
}

function solve(n: Network, maxTime: number, moveFunc: (Network, State) => Iterable<State>) {

	let states = [ new State() ];
	let max = 0;
	for (let minute = 1; minute < maxTime; ++minute) {
		const next: State[] = [];
		for (const state of states) {
			for (const move of moveFunc(n, state)) {
				advance(n, move);
				next.push(move);
				if (move.total > max) max = move.total;
			}
		}
		console.log(`Minute: ${minute} max: ${max}`);
		next.sort((a, b) => b.total - a.total);
		assert(next[0].total === max);
		states = next.slice(0, 10000);
	}
	return max;
}

const testData = parse("test-input");
const data = parse("input");

assert(solve(testData, 30, possibleMoves) === 1651);
solve(data, 30, possibleMoves); // 1857

assert(solve(testData, 26, possibleMoves2) === 1707);
solve(data, 26, possibleMoves2); // 2536
