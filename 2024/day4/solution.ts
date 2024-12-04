#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';

type Data = string[];

function parse(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' }).split('\n').filter(i => i !== '');
	return data;
}

function search(data: string[], x: number, y: number, dx: number, dy: number) {
	
	function inRange(x: number, y: number) {
		return x >= 0 && y >= 0 && x < data[0].length && y < data.length; 
	}

	let NEEDLE = 'XMAS';
	let xx = x;
	let yy = y;

	for (let pos = 0; pos < 4; ++pos) {
		if (!inRange(xx, yy)) return false;
		if(data[yy][xx] !== NEEDLE[pos]) return false;
		xx += dx;
		yy += dy;
	}
	return true;
}

function solve1(data: Data) {
	let result = 0;


	for (let y = 0; y < data.length; ++y) {
		for (let x = 0; x < data[0].length; ++x) {
			// for each position
			// if it's an X
			// count xmas in 8 directions
			if (data[y][x] === 'X') {
				let dx = 1; let dy = 0;
				let ddx = 1; let ddy = 1;
				for (let i = 0; i < 4; ++i) {
					if (search(data, x, y, dx, dy)) result++;
					if (search(data, x, y, ddx, ddy)) result++;
					[dx, dy] = [-dy, dx];
					[ddx, ddy] = [-ddy, ddx];
				}
			}
		}
	}
	return result;
}

// function solve2(data: Data) {
// 	let result = 0;
// 	return result;
// }

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve1(data));
// console.log(solve2(data));
