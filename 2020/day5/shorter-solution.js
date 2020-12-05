#!/usr/bin/env node

import { readLinesGenerator } from '../common/readers.js';

async function main() {
	const CODE_TO_BINARY = { 'F': 0, 'B': 1, 'R': 1, 'L': 0 }
	
	let data = [], byIndex = [];
	for await (const line of readLinesGenerator('input')) {
		const binary = line.split('').map(ch => CODE_TO_BINARY[ch]).join('');
		const seat = parseInt(binary, 2);
		byIndex[seat] = 1;
		data.push(seat);
	}

	const max = Math.max(...data);
	const min = Math.min(...data);
	console.log("Highest seat: ", max);
	console.log("Lowest seat: ", min);

	for (let i = min; i < max; ++i) {
		if (!(i in byIndex)) {
			console.log("Missing seat: ", i)
		}
	}
}

main();
