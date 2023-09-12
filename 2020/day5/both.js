#!/usr/bin/env node

import { readLinesGenerator } from '../common/readers.js';

function rowToSeat(line) {
	const CODE_TO_BINARY = {
		'F': 0,
		'B': 1,
		'R': 1,
		'L': 0
	}
	 
	const digits = line.split('').map(ch => CODE_TO_BINARY[ch]);
	let seat = 0;
	for (const bit of digits) {
		seat *= 2;
		seat += bit;
	}
	// console.log ({line, digits, seat, row: Math.floor(seat / 8), col: seat % 8});
	return seat;
}

async function main() {
	
	let max = 0;
	let min = 1000000;
	let seats = [];
	for await (const line of readLinesGenerator('input')) {
		const seat = rowToSeat(line);
		if (seat > max) {
			max = seat;
		}
		if (seat < min) {
			min = seat;
		}
		seats[seat] = 1;
	}
	console.log("Highest seat: ", max);
	console.log("Lowest seat: ", min);

	for (let i = min; i < max; ++i) {
		if (!(i in seats)) {
			console.log("Missing seat: ", i)
		}
	}
}

main();
