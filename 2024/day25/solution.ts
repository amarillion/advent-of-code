#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';

type Data = {
	keys: number[][],
	locks: number[][]
}

function parse(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' }).split('\n\n').map(chunk => chunk.split('\n').filter(i => i !== ''));

	const chunkSet = new Set<string>();
	const locks: number[][] = [];
	const keys: number[][] = [];
	for (const chunk of data) {
		const chunkKey = chunk.join('\n');
		assert(!chunkSet.has(chunkKey));
		chunkSet.add(chunkKey);
		let isLock = (chunk[0] === '#####');
		const delta = isLock ? 1 : -1;
		let counter;
		let row: number[] = [];
		for (let x = 0; x < 5; ++x) {
			let y = isLock ? 1: chunk.length - 2;
			for (counter = 0; counter < chunk.length; ++counter) {
				if (chunk[y][x] === '.') {
					break;
				}
				y += delta;
			}
			row.push(counter);
		}
		if (isLock) {
			locks.push(row);
		}
		else {
			keys.push(row);
		}
	}

	// unique pairs...

	return { locks, keys };
}

function hasOverlap(key: number[], lock: number[]) {
	for (let i = 0; i < 5; ++i) {
		if (key[i] + lock[i] > 5) { return true; }
	}
	return false;
}

function solve1(data: Data) {
	console.log(data);
	let result = 0;

	for (let kk = 0; kk < data.keys.length; ++kk) {
		for (let ll = 0; ll < data.locks.length; ++ll) {
			const overlaps = hasOverlap(data.keys[kk], data.locks[ll]);
			if (!overlaps) { result++; }
		}
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
