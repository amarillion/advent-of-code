#!/usr/bin/env ts-node
import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';


function parse(fname: string) {
	let lines = readFileSync(fname).toString('utf-8').split('\n');

	const route = lines[0];
	const nodes: Record<string, [string, string]> = {};
	for (const line of lines.slice(2, -1)) {
		const matcher = line.match(/(?<src>\w{3}) = \((?<left>\w{3}), (?<right>\w{3})\)/);
		assert(matcher && matcher.groups);
		const { src, left, right } = matcher.groups;
		console.log({src, left, right});
		nodes[src] = [ left, right ];
	}
	return {
		route, nodes
	}
}

type Data = ReturnType<typeof parse>;

function solve1(data: Data) {
	let pos = 'AAA';
	let steps = 0;

	while (pos !== 'ZZZ') {
		let instruction = data.route[steps % data.route.length];
		let newPos;
		if (instruction === 'L') {
			newPos = data.nodes[pos][0];
		}
		else {
			newPos = data.nodes[pos][1];
		}
		console.log(`Step: ${instruction} from ${pos} to ${newPos}`);
		pos = newPos;
		assert(pos in data.nodes);
		steps++;
	}
	console.log(steps);
	return steps;
}

const testInput = parse("test-input");
assert(solve1(testInput) === 2);

const input = parse("input");
console.log(solve1(input));