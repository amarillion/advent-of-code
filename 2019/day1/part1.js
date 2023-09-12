#!/usr/bin/env node

import { readLinesGenerator } from '../common/readers.js';

async function main() {	
	let sum = 0;
	for await (const line of readLinesGenerator('input')) {
		sum += Math.floor((+line) / 3) - 2
	}
	console.log(sum);
}

main();
