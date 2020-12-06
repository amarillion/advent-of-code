#!/usr/bin/env node

import { paragraphGenerator, readLinesGenerator } from '../common/readers.js';

async function main() {	
	let sum = 0;
	for await (const group of paragraphGenerator('input')) {
		const set = group.join('').split('').reduce((acc, cur) => acc.add(cur), new Set());
		console.log(set.size);
		sum += set.size;
	}
	console.log(sum);
}

main();
