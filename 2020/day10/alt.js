#!/usr/bin/env node

import { readNumbers } from '../common/readers.js';

async function main() {	
	
	const data = await readNumbers('input');
	data.sort((a,b) => a-b);
	
	// start & end markers
	data.push(data[data.length-1] + 3);
	data.unshift(0);

	// store partial counts from given positions to end.
	const partialCount = {};
	// seed with the last step
	partialCount[data.length-1] = 1;

	// walk backwards, caching partial calculations
	for (let pos = data.length-2; pos >= 0; pos--) {
		let count = 0;
		for (let i = pos + 1; i < data.length; ++i) {
			// inner loop only continues until the gap is larger than 3
			if (data[i] - data[pos] > 3) {
				break;
			}
			// count is sum of the partial counts that can be reached from here.
			count += partialCount[i];
		}
		partialCount[pos] = count;
	}

	// final result is the last stored partialCount
	console.log(partialCount[0]);
}

main();
