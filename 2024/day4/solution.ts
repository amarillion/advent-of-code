#!/usr/bin/env tsx

import { assert } from '../common/assert.js';
import { ValueGrid, readGridFromFile, walk } from '../common/grid.js';
import { take } from '../common/iterableUtils.js';
import { pointRange } from '../common/geom/pointRange.js';

function search(grid: ValueGrid<string>, x: number, y: number, dx: number, dy: number) {
	const scan = take(walk(grid, x, y, dx, dy), 4).join('');
	return scan === 'XMAS';
}

function solve1(grid: ValueGrid<string>) {
	let result = 0;

	for (const {x, y} of pointRange(grid.width, grid.height)) {
		// for each position
		// if it's an X
		// count xmas in 8 directions
		if (grid.get({ x, y }) === 'X') {
			let dx = 1; let dy = 0;
			let ddx = 1; let ddy = 1;
			for (let i = 0; i < 4; ++i) {
				if (search(grid, x, y, dx, dy)) result++;
				if (search(grid, x, y, ddx, ddy)) result++;
				[dx, dy] = [-dy, dx];
				[ddx, ddy] = [-ddy, ddx];
			}
		}
	}
	return result;
}

function searchCross(grid: ValueGrid<string>, x: number, y: number) {
	let dx = 1;
	let dy = 1;
	const scan = take(walk(grid, x - dx, y - dy, dx, dy), 3).join('');
	if (scan === 'MAS' || scan === 'SAM') {
		[dx, dy] = [-dy, dx];
		const ortho = take(walk(grid, x - dx, y - dy, dx, dy), 3).join('');
		return (ortho === 'MAS' || ortho === 'SAM');
	}
	return false;
}

function solve2(grid: ValueGrid<string>) {
	let result = 0;
	for (const { x, y } of pointRange(grid.width, grid.height)) {
		if (grid.get({ x, y }) === 'A') {
			if (searchCross(grid, x, y)) {
				result++;
			}
		}
	}
	return result;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = readGridFromFile(process.argv[2]);
console.log(solve1(data));
console.log(solve2(data));
