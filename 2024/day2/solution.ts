#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';

function parse(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' }).split('\n').filter(i => i !== '');
	return data.map(line => line.split(' ').map(Number));
}

function rowSafe(row: number[]) {
	const deltas: number[] = [];
	for (let i = 1; i < row.length; ++i) {
		deltas.push(row[i] - row[i-1]);
	}

	return (deltas.every(i => i >= 1 && i <= 3) || 
		deltas.every(i => i >= -3 && i <= -1));
}

function solve1(data: number[][]) {
	return data.filter(rowSafe).length;
}

function solve2(data: number[][]) {
	let result = 0;
	for(const line of data) {
		let safe = rowSafe(line);
		if (!safe) {
			for (let i = 0; i < line.length; ++i) {
				const dampened = line.slice();
				dampened.splice(i, 1);
				if (rowSafe(dampened)) {
					safe = true;
					break;
				}
			}
		}
		if (safe) { result++; }
	}
	return result;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve1(data));
console.log(solve2(data));
