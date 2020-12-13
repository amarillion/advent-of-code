#!/usr/bin/env node

import { readLines } from '../common/readers.js';

async function main() {	

	const lines = await readLines('input');
	const now = + lines[0];
	const buses = lines[1].split(',').filter(v => v !== 'x').map(d => +d);
	console.log({ now });
	let min = now;
	let minBus = 0;
	for (const bus of buses) {
		let round = Math.floor(now / bus);
		let nextDeparture = bus * round;
		if (nextDeparture < now) nextDeparture += bus;
		let wait = nextDeparture - now;
		if (wait < min) {
			min = wait;
			minBus = bus;
		}
		console.log(bus, round, nextDeparture, wait);
	}
	console.log('Next bus: ', min, minBus, 'Answer:', min * minBus);
}

main();
