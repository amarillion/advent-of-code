#!/usr/bin/env ts-node

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

type Network = { [key: string]: Node };

function parse(fname: string) {
	let raw = readFileSync(fname).toString('utf-8');
	let lines = raw.split('\n');

	const result: Network = {};
	for (const line of lines) {
		if (line === "") continue;
		const matcher = line.match(/Valve (?<id>\w+) has flow rate=(?<rate>\d+); tunnels? leads? to valves? (?<exits>.*)/);
		assert(Boolean(matcher), `Couldn't parse [${line}]`);
		const { id, rate, exits } = matcher.groups;
		result[id] = {
			id,
			rate: +rate,
			exits: exits.split(", ")
		};
		console.log(id, +rate, result[id].exits);
	}
	return result;
}

class State {
	minute = 1;
	open = new Set<string>();
	position = "AA";
	sum = 0;

	copy() {
		const result = new State();
		result.minute = this.minute;
		result.open = new Set<string>(this.open);
		result.position = this.position;
		result.sum = this.sum;
		return result;
	}
}

function advance(n: Network, s: State) {
	s.minute++;
	s.open.forEach(valve => {
		assert(valve in n, `Missing vale ${valve}`);
		s.sum += n[valve].rate
	});
}

function *possibleMoves(n: Network, s: State) {
	if (!s.open.has(s.position)) {
		const move = s.copy();
		move.open.add(s.position);
		advance(n, move);
		yield move;
	}
	for (const exit of n[s.position].exits) {
		const move = s.copy();
		move.position = exit;
		advance(n, move);
		yield move;
	}
}

function solve(n: Network) {

	let states = [ new State() ];
	let max = 0;
	for (let minute = 1; minute < 30; ++minute) {
		const next: State[] = [];
		for (const state of states) {
			for (const move of possibleMoves(n, state)) {
				next.push(move);
				if (move.sum > max) max = move.sum;
			}
		}
		console.log(`Minute: ${minute} max: ${max}`);
		next.sort((a, b) => b.sum - a.sum);
		assert(next[0].sum === max);
		states = next.slice(0, 1000);
	}

	/*
	simulation:
	1. move to exit
	2. open valve (if not open)

	State: turn, current location, set of open valves
	*/
	return max;
}

assert(solve(parse("test-input")) === 1651);
solve(parse("input"));