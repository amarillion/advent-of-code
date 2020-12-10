#!/usr/bin/env node

import { readNumbers } from '../common/readers.js';

const cache = new Map();
let cacheMisses = 0;

function hash(obj) {
	return JSON.stringify(obj);
}

function nextPossibilities(cur, start, data) {
	if (cache.has(hash([cur, start]))) {
		return cache.get(hash([cur, start]));
	}
	cacheMisses++;
	let count = 0;

	if (start === data.length) {
		return 1;
	}

	for (let i = start; i < data.length; ++i) {
		if (data[i] - cur > 3) {
			break;
		}
		count += nextPossibilities(data[i], i + 1, data);
	}

	cache.set(hash([cur, start]), count);
	return count;
}

async function main() {	
	
	let data = await readNumbers('input');
	data.sort((a,b) => a-b);
	
	// end marker
	data.push(data[data.length-1] + 3);
	
	console.log(data);

	let part2 = nextPossibilities(0, 0, data);
	console.log(cache);
	console.log('Cache misses', cacheMisses);
	console.log(part2);
}

main();
