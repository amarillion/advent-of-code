#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';

type Data = number[];

function parse(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' }).split('\n')[0].split(' ').map(Number);
	return data;
}

function solve1(data: Data) {
	let stones = data.slice();
	for (let i = 0; i < 25; ++i) {
		stones = stones.flatMap(num => {
			if (num === 0) {
				return 1;
			}
			else if (`${num}`.length % 2 === 0) {
				const numStr = `${num}`;
				const numLen = numStr.length;
				return [ numStr.substring(0, numLen / 2),
					numStr.substring(numLen / 2) ].map(Number);
			}
			else {
				return num * 2024;
			}
		});
		console.log(stones);
	}
	
	return stones.length;
}

// function solve2(data: Data) {
// 	let result = 0;
// 	return result;
// }

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve1(data));
// console.log(solve2(data));
