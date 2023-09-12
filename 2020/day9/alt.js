#!/usr/bin/env node

import { assert } from '../common/assert.js';
import { readNumbers } from '../common/readers.js';
import { allPairs, allSlices } from '../common/combinations.js';

function findSum(data, sum) {
	for (const pair of allPairs(data)) {
		if (pair[0] + pair[1] === sum) return true;
	}
	return false;
}

function findContiguousSum(data, expect) {
	for (let sl of allSlices(data)) {
		let sum = sl.reduce((acc, cur) => acc + cur, 0);
		if (sum === expect) {
			let max = Math.max(...sl);
			let min = Math.min(...sl);
			console.log(max + min);
			return;
		}
	}
}

async function main() {	
	let data = await readNumbers('input');

	let preamble = 25;
	for (let i = preamble; i < data.length; ++i) {
		let check = findSum(data.slice(i - preamble, i), data[i]);
		if (!check) {
			console.log(data[i]);
			findContiguousSum(data.slice(0,i), data[i]);
			return;
		}
	}
}

main();
