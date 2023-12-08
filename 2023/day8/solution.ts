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

function solve2(data: Data) {

	const cycleData: Record<string, number[]> = {};
	let pos = Object.keys(data.nodes).filter(s => s.endsWith("A"));
	let steps = 0;

	while (pos.some(s => !s.endsWith("Z"))) {
		let instruction = data.route[steps % data.route.length];
		const index = instruction === 'L' ? 0 : 1;

		const newPos = pos.map(node => data.nodes[node][index])

		let countZ = 0;
		for (let j = 0; j < pos.length; ++j) {
			const p = pos[j];
			if (p.endsWith("Z")) {
				countZ++;
				const key = `${j}:${p}`;
				if (key in cycleData) {
					let prev = cycleData[key][cycleData[key].length-1];
					cycleData[key].push(steps = prev);
				}
				else {
					cycleData[key] = [ steps ];
				}
			}
		}

		if (steps < 10 || countZ > 0) {
			console.log(`Step: ${steps} ${instruction} from ${pos} to ${newPos}`);
			console.log(cycleData);
		}
		pos = newPos;
		assert(pos.every(p => p in data.nodes));
		steps++;
		if (steps > 10_000) { break; }
	}
	console.log(steps);
	return steps;
}

const testInput = parse("test-input");
assert(solve1(testInput) === 2);

const testInput2 = parse("test-input");
assert(solve2(testInput2) === 2);

const input = parse("input");
console.log(solve1(input));
console.log(solve2(input));

// TODO: calculate GCD automatically...
// Using online GCD tool:
console.log(73 * 67 * 61 * 59 * 53 * 47) // Too low: 43848348119
console.log(73 * 67 * 61 * 59 * 53 * 47 * 269) // 11795205644011
console.log(
	BigInt("19637") * BigInt("18023") * BigInt("16409") * BigInt("15871") * BigInt("14257") * BigInt("12643"));