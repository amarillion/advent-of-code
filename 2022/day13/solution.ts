#!/usr/bin/env ts-node

import { readFileSync } from 'fs';
import { assert } from '@amarillion/helixgraph/lib/assert.js';

function readData(fname: string) {
	const lines = readFileSync(fname).toString('utf-8').split('\n');
	const result: unknown[][] = [];
	for (let i = 0; i < lines.length; i += 3) {
		const a = JSON.parse(lines[i]);
		const b = JSON.parse(lines[i+1]);
		result.push([a, b]);
	}
	return result;
}

function compare(_a: unknown, _b: unknown) {
	let a = _a;
	let b = _b;

	if (typeof(a) === 'number' && typeof(b) === 'number') {
		return a-b;
	}
	
	if (typeof(a) === 'number' && Array.isArray(b)) {
		a = [ a ];
	}
	else if (typeof(b) === 'number' && Array.isArray(a)) {
		b = [ b ];
	}

	
	// now both must be arrays
	assert(Array.isArray(a) && Array.isArray(b)) 
	
	let i = 0;
	while(true) {
		if (a.length === i && b.length === i) return 0;
		else if (a.length === i) return -1;
		else if (b.length === i) return 1;
		
		const c = compare(a[i], b[i]);
		if (c !== 0) return c;
		
		i++; // on to next element in list
	}
	
}

function solve1(pairs: unknown[][]) {
	let i = 1;
	let sum = 0;
	for (const pair of pairs) {
		const cmp = compare(pair[0], pair[1]); 
		// console.log(pair, cmp);
		if (cmp < 0) {
			// console.log(`Pair ${i} is in the right order`);
			sum += i;
		}
		else {
			// console.log(`Pair ${i} is in the wrong order`);
		}
		i++;
	}
	console.log("Result: ", sum);
}

function solve2(pairs: unknown[][]) {
	let result: unknown[] = [];
	for (const p of pairs) {
		result.push(p[0]);
		result.push(p[1]);
	}

	const div1 = [[2]];
	const div2 = [[6]];

	result.push(div1);
	result.push(div2);
	result.sort(compare);

	let product = 1;
	for (let i = 0; i < result.length; ++i) {
		if (result[i] === div1) product *= (i+1);
		if (result[i] === div2) product *= (i+1);
	}
	console.log("Part 2: ", product);
}

const testPairs = readData('test-input');
solve1(testPairs);
solve2(testPairs);

const pairs = readData('input');
solve1(pairs);
solve2(pairs);
