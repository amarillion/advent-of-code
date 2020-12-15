#!/usr/bin/env node

import { readLines } from '../common/readers.js';

async function main() {	
	
	const data = (await readLines('test')).join('').split(',').map(a => +a);
	
	const lastSpoken = {};

	let round = 1;
	for (let i = 0; i < data.length-1; ++i) {
		lastSpoken[data[i]] = round;
		round++;
	}
	
	console.log(data, lastSpoken);

	round++;
	let prev = data[data.length-1];
	
	while (round <= 2020) {
		let number;
		if (prev in lastSpoken) {
			number = (round - 1 - lastSpoken[prev]);
		}
		else {
			number =  0;
		}

		console.log(`Round: ${round} - Number: ${number}`);
		
		lastSpoken[prev] = round-1;
		prev = number;
		round++;
	}
}

main();
