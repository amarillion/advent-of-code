#!/usr/bin/env node

import { readLines } from '../common/readers.js';

async function main() {	

	const lines = await readLines('input');
	const buses = lines[1].split(',');
	let busData = [];
	for (let i = 0; i < buses.length; ++i) {
		if (buses[i] !== 'x') {
			busData.push({
				bus: +buses[i],
				order: i
			});
		}
	}
	busData.sort((a, b) => b.bus - a.bus);

	let noMatch = true;
	let increment = 1;
	// let ts = 1;
	let ts = 100000000000000;
	while(noMatch) {
		noMatch = false;
		console.log(`Timestamp: ${ts} Increment ${increment}`);
		let newIncrement = 1;
		for (const theBus of busData) {
			if (((ts + theBus.order) % theBus.bus) === 0) {
				console.log(`${theBus.bus} departs at ${ts} + ${theBus.order}`);
				newIncrement *= theBus.bus;
			}
			else {
				noMatch = true;
				break;
			}
		}
		increment = newIncrement;
		ts += increment;
	}
}

main();
