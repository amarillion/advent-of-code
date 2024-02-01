#!/usr/bin/env tsx
import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';
import { LCM } from '../common/numbers.js';

function parse(fname: string) {
	let lines = readFileSync(fname).toString('utf-8').split('\n');

	const route = lines[0];
	const nodes: Record<string, [string, string]> = {};
	for (const line of lines.slice(2, -1)) {
		const matcher = line.match(/(?<src>\w{3}) = \((?<left>\w{3}), (?<right>\w{3})\)/);
		assert(matcher && matcher.groups);
		const { src, left, right } = matcher.groups;
		// console.log({src, left, right});
		nodes[src] = [ left, right ];
	}
	return {
		route, nodes
	}
}

type Data = ReturnType<typeof parse>;

/** Follow the graph from src, alternating directions according to the defined route.
 *  Count the number of steps to reach a destination node. */
function findCycleLength(data: Data, src: string, isDest: (s: string) => boolean) {
	let pos = src;
	let steps = 0;
	while (!isDest(pos)) {
		let instruction = data.route[steps % data.route.length];
		const index = instruction === 'L' ? 0 : 1;
		pos = data.nodes[pos][index];
		steps++;
	}
	return steps;
}

function solve2(input: Data) {
	const lcm = Object
		 // of all nodes
		.keys(input.nodes)
		// take the ones ending with A
		.filter(s => s.endsWith("A"))
		// count the steps until we reach a node ending with Z
		.map(src => findCycleLength(input, src, s => s.endsWith("Z")))
		// find the least common multiple of all cycle lengths together
		.reduce((cur: number, acc: number) => LCM(cur, acc), 1);
	
	return lcm;
}

assert(process.argv.length == 3, "Expected argument: input file");
const fname = process.argv[2];
const data = parse(fname);
console.log(findCycleLength(data, "AAA", (src) => src === "ZZZ"));
console.log(solve2(data));
