#!/usr/bin/env node

import { paragraphGenerator } from '../common/readers.js';

async function main() {	
	let sum = 0;
	for await (const group of paragraphGenerator('input')) {
		const data = {};
		for (const line of group) {
			const chars = line.split('');
			for(const cur of chars) {
				if (cur in data) {
					data[cur] += 1;
				}
				else {
					data[cur] = 1;
				}
			}
		}
		let count = Object.values(data).filter(d => d === group.length).length;
		console.log(data, count);
		sum += count;
	}
	console.log(sum);
}

main();
