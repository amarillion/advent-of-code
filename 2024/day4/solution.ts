#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';

type Data = string[];

function parse(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' }).split('\n').filter(i => i !== '');
	return data;
}

function inRange(data: string[], x: number, y: number) {
	return x >= 0 && y >= 0 && x < data[0].length && y < data.length; 
}

function *walk(data: string[], x: number, y: number, dx: number, dy: number) {
	let xx = x;
	let yy = y;
	while (inRange(data, xx, yy)) {
		yield data[yy][xx]
		xx += dx;
		yy += dy;	
	}
}

function take<T>(generator: Generator<T>, num: number) {
	const result: T[] = [];
	let i = 0;
	for (const val of generator) {
		result.push(val);
		i++;
		if (i === num) { return result; }
	}
	return result;
}

function search(data: string[], x: number, y: number, dx: number, dy: number) {
	const scan = take(walk(data, x, y, dx, dy), 4).join('');
	return scan === 'XMAS';
}

function eachRange(width: number, height: number, callback: (x: number, y: number) => void) {
	for (let y = 0; y < width; ++y) {
		for (let x = 0; x < height; ++x) {
			callback(x, y);
		}
	}
}

function solve1(data: Data) {
	let result = 0;

	eachRange(data[0].length, data.length, ( x, y ) => {
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
	});
	return result;
}

function searchCross(data: string[], x: number, y: number) {
	let dx = 1;
	let dy = 1;
	const scan = take(walk(data, x - dx, y - dy, dx, dy), 3).join('');
	if (scan === 'MAS' || scan === 'SAM') {
		[dx, dy] = [-dy, dx];
		const ortho = take(walk(data, x - dx, y - dy, dx, dy), 3).join('');
		return (ortho === 'MAS' || ortho === 'SAM');
	}
	return false;
}

function solve2(data: Data) {
	let result = 0;
	eachRange(data[0].length, data.length, (x, y) => {
		if (data[y][x] === 'A') {
			if (searchCross(data, x, y)) {
				result++;
			}
		}
	});
	return result;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve1(data));
console.log(solve2(data));
