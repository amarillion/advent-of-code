#!/usr/bin/env node

import { readMatrix } from '../common/readers.js';

async function main() {	
	let sum = 0;
	const matrix = await readMatrix('output');
	const width = matrix[0].length;
	const height = matrix.length;
	
	for (let x = 1; x < width - 1; ++x) {
		for (let y = 1; y < height - 1; ++y) {
		
			if (
				   matrix[y  ][x] === '#' 
				&& matrix[y+1][x] === '#' 
				&& matrix[y-1][x] === '#' 
				&& matrix[y  ][x-1] === '#' 
				&& matrix[y  ][x+1] === '#' 
			) {
				sum += x * y;
			}
		}
	}
	console.log(sum);
}

main();
