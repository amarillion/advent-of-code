#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';
import { skip } from '../common/iterableUtils.js';
import { DefaultMap } from '../common/DefaultMap.js';

type Data = number[];

function parse(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' }).split('\n').filter(i => i !== '').map(Number);
	return data;
}

function doStep(value: number) {
	value = ((value << 6) ^ value) & 16777215;
	value = ((value >> 5) ^ value) & 16777215;
	value = ((value << 11) ^ value) & 16777215;
	return value;
}

function *randomGenerator(seed: number) {
	let value = seed;
	while(true) {
		value = doStep(value);
		yield(value);
	}
}

function indexSequences(randomize: Generator<number>, count: number) {
	const diffs: number[] = [];
	let prev = (randomize.next().value % 10);
	let firstValueMap = new Map<string, number>();
	let i = 1;
	for (const value of randomize) {
		let price = value % 10;
		let delta = price - prev;
		diffs.push(delta);
		if (diffs.length === 4) {
			const key = JSON.stringify(diffs);
			if (!firstValueMap.has(key)) {
				firstValueMap.set(key, price);
			}

			diffs.shift();
		}
		prev = price;
		if (++i === count) break;
	}
	return firstValueMap;
}

function solve1(data: Data) {
	let result = 0;

	for (const row of data) {
		const value = skip(randomGenerator(row), 2000)!;
		result += value;
	}
	return result;
}

function solve2(data: Data) {
	const totalValueMap = new DefaultMap<string, number>(0);
	for (const row of data) {
		const firstValueMap = indexSequences(randomGenerator(row), 2000);
		for (const [key, price] of firstValueMap.entries()) {
			totalValueMap.update(key, val => val + price);
		}
	}

	// console.log(formatMap(totalValueMap, 50, (a: number, b: number) => b - a));

	let maxKey = '';
	let max = 0;
	for (const [key, total] of totalValueMap.entries()) {
		if (total > max) {
			max = total;
			maxKey = key;
		}
	}
	// console.log(max, maxKey);
	return max;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve1(data));
console.log(solve2(data));
