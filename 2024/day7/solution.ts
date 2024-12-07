#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';

type Data = { answer: number, inputs: number[] }[];

function parse(fname: string) {
	const result: Data = [];
	for (const raw of readFileSync(fname, { encoding: 'utf-8' }).split('\n').filter(i => i !== '')) {
		const fields = raw.split(': ');
		result.push({ answer: Number(fields[0]), inputs: fields[1].split(' ').map(Number) });
	}
	return result;
}

function hasPossibleResults(expected: number, inputs: number[], part2 = false) {
	assert(inputs.length > 0);
	if (inputs.length === 1) {
		return expected === inputs[0];
	}
	const remain = inputs.slice();
	const first = remain.pop();
	assert(first);

	if (part2) {
		const expectedStr = `${expected}`;
		const firstStr = `${first}`;
		if (`${expected}`.endsWith(`${first}`)) {
			if (hasPossibleResults(Number(expectedStr.substring(0, expectedStr.length - firstStr.length)), remain, part2)) {
				return true;
			}
		}	
	}

	// only checking integer division
	if (expected % first === 0) {
		if (hasPossibleResults(expected / first, remain, part2)) {
			return true;
		}
	}

	return hasPossibleResults(expected - first, remain, part2);
}

function solve(data: Data, part2: boolean) {
	let result = 0;
	for (const row of data) {
		if (hasPossibleResults(row.answer, row.inputs, part2)) {
			result += row.answer;
		}
	}
	return result;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve(data, false));
console.log(solve(data, true));
