#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';
import { DefaultMap } from '../common/DefaultMap.js';
import { sum } from '../common/iterableUtils.js';

type Data = number[];

function parse(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' }).split('\n')[0].split(' ').map(Number);
	return data;
}

function isEvenLen(val: number) {
	return `${val}`.length % 2 === 0
}

function splitDigits(val: number) {
	const valStr = `${val}`;
	const len = valStr.length;
	return [ 
		valStr.substring(0, len / 2),
		valStr.substring(len / 2) 
	].map(Number);
}

function solve(data: Data, iterations: number) {
	let stones = new DefaultMap<number, number>(0);
	for (const i of data) { stones.update(i, val => val + 1); }
	for (let i = 0; i < iterations; ++i) {
		const newIteration = new DefaultMap<number, number>(0);
		for (const [key, num] of stones.entries()) {
			if (key === 0) {
				newIteration.update(1, val => val + num);
			}
			else if (isEvenLen(key)) {
				splitDigits(key).forEach(k => {
					newIteration.update(k, val => val + num);
				});
			}
			else {
				newIteration.update(key * 2024, val => val! + num);
			}
		}
		stones = newIteration;
	}
	return sum(stones.values());
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve(data, 25));
console.log(solve(data, 75));
