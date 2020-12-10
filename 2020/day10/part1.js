#!/usr/bin/env node

import { readNumbers } from '../common/readers.js';

async function main() {	
	
	let data = await readNumbers('input');
	data.sort((a,b) => a-b);
	console.log(data);

	let result = [];
	for (let i = 1; i < data.length; ++i) {
		let delta = data[i] - data[i-1];
		console.log(delta);
		result.push(delta);
	}

	let threes = result.filter(i => i === 3).length;
	let ones = result.filter(i => i === 1).length;
	
	console.log('Threes:', threes, 'Ones: ', ones, (threes + 1) * (ones + 1));
}

main();
