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

function hasPossibleResults(expected: number, inputs: number[]) {
	// console.log("Checking", { expected, inputs });
	assert(inputs.length > 0);
	if (inputs.length === 1) {
		return expected === inputs[0];
	}
	const remain = inputs.slice();
	const first = remain.pop();
	assert(first);
	return hasPossibleResults(expected - first, remain) ||
		hasPossibleResults(expected / first, remain);
}

function solve1(data: Data) {
	let result = 0;
	for (const row of data) {
		if (hasPossibleResults(row.answer, row.inputs)) {
			// console.log("Match", row);
			result += row.answer;
		}
	}
	return result;
}

function hasPossibleResultsExt(expected: number, inputs: number[]) {
	// console.log("Checking", { expected, inputs });
	assert(inputs.length > 0);
	if (inputs.length === 1) {
		return expected === inputs[0];
	}
	const remain = inputs.slice();
	const first = remain.pop();
	assert(first);
	const expectedStr = `${expected}`;
	const firstStr = `${first}`;
	if (`${expected}`.endsWith(`${first}`)) {
		if (hasPossibleResultsExt(Number(expectedStr.substring(0, expectedStr.length - firstStr.length)), remain)) {
			return true;
		}
	}
	return hasPossibleResultsExt(expected - first, remain) ||
		hasPossibleResultsExt(expected / first, remain);
}

// 7290
// 7290 / 15 = 486
// endsWith first

function solve2(data: Data) {
	let result = 0;
	for (const row of data) {
		if (hasPossibleResultsExt(row.answer, row.inputs)) {
			// console.log("Match", row);
			result += row.answer;
		}
	}
	return result;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve1(data));
console.log(solve2(data));
