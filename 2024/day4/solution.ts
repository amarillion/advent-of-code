#!/usr/bin/env tsx

import { assert } from '../common/assert.js';
import { eachRange, type Grid, readGridFromFile, take, walk } from '../common/grid.js';

function search(grid: Grid, x: number, y: number, dx: number, dy: number) {
	const scan = take(walk(grid, x, y, dx, dy), 4).join('');
	return scan === 'XMAS';
}

function solve1(grid: Grid) {
	let result = 0;

	eachRange(grid[0].length, grid.length, ( x, y ) => {
		// for each position
		// if it's an X
		// count xmas in 8 directions
		if (grid[y][x] === 'X') {
			let dx = 1; let dy = 0;
			let ddx = 1; let ddy = 1;
			for (let i = 0; i < 4; ++i) {
				if (search(grid, x, y, dx, dy)) result++;
				if (search(grid, x, y, ddx, ddy)) result++;
				[dx, dy] = [-dy, dx];
				[ddx, ddy] = [-ddy, ddx];
			}
		}
	});
	return result;
}

function searchCross(grid: Grid, x: number, y: number) {
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

function solve2(grid: Grid) {
	let result = 0;
	eachRange(grid[0].length, grid.length, (x, y) => {
		if (grid[y][x] === 'A') {
			if (searchCross(grid, x, y)) {
				result++;
			}
		}
	});
	return result;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = readGridFromFile(process.argv[2]);
console.log(solve1(data));
console.log(solve2(data));
