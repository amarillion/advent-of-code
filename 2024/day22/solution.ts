#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';

type Data = number[];

function parse(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' }).split('\n').filter(i => i !== '').map(Number);
	return data;
}

function doStep(value: number) {
	/*
	In particular, each buyer's secret number evolves into the next secret number in the sequence via the following process:

    Calculate the result of multiplying the secret number by 64. Then, mix this result into the secret number. Finally, prune the secret number.
    Calculate the result of dividing the secret number by 32. Round the result down to the nearest integer. Then, mix this result into the secret number. Finally, prune the secret number.
    Calculate the result of multiplying the secret number by 2048. Then, mix this result into the secret number. Finally, prune the secret number.

Each step of the above process involves mixing and pruning:

    To mix a value into the secret number, calculate the bitwise XOR of the given value and the secret number. Then, the secret number becomes the result of that operation. (If the secret number is 42 and you were to mix 15 into the secret number, the secret number would become 37.)
    To prune the secret number, calculate the value of the secret number modulo 16777216. Then, the secret number becomes the result of that operation. (If the secret number is 100000000 and you were to prune the secret number, the secret number would become 16113920.)

*/
	value = ((value << 6) ^ value) & 16777215;
	value = ((value >> 5) ^ value) & 16777215;
	value = ((value << 11) ^ value) & 16777215;
	return value;
}

function applySteps(row: number, times: number) {
	let next = row;
	// console.log(row);
	for (let i = 0; i < times; ++i) {
		next = doStep(next);
		// console.log(next);
	}
	return next;
}

function solve1(data: Data) {
	let result = 0;

	for (const row of data) {
		const value = applySteps(row, 2000);
		result += value;
	}
	return result;
}

// function solve2(data: Data) {
// 	let result = 0;
// 	return result;
// }

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve1(data));
// console.log(solve2(data));
// applySteps(123, 10);