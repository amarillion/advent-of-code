#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';

type Grid = string[][];

function parse(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' }).split('\n').filter(i => i !== '').map(line => [...line]);
	return data;
}

function inRange(data: string[][], x: number, y: number) {
	return x >= 0 && y >= 0 && x < data[0].length && y < data.length; 
}

function *walk(data: string[][], x: number, y: number, dx: number, dy: number) {
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

function eachRange(width: number, height: number, callback: (x: number, y: number) => void) {
	for (let y = 0; y < width; ++y) {
		for (let x = 0; x < height; ++x) {
			callback(x, y);
		}
	}
}

function find(grid: Grid, needle: string) {
	const width = grid[0].length;
	const height = grid.length;
	for (let y = 0; y < width; ++y) {
		for (let x = 0; x < height; ++x) {
			if (grid[y][x] === needle) {
				return { x, y };
			}
		}
	}
	return null;
}

function analyseWalk(grid: Grid) {
	let visited = 1;
	let pos = find(grid, '^');
	let delta = { x: 0, y : -1 };
	const states = new Set<string>()
	while(true) {
		assert(pos !== null);
		const newPos = { x: pos.x + delta.x, y: pos.y + delta.y };
		if (!inRange(grid, newPos.x, newPos.y)) {
			return {
				infinite: false,
				visited
			};
		}

		const char = grid[newPos.y][newPos.x];
		if (char === '#' || char === 'O') {
			// rotate 90 degrees
			delta = { x: -delta.y, y: delta.x };
		}
		else if (char === '.') {
			pos = newPos;
			grid[pos.y][pos.x] = 'X';
			visited += 1;
		}
		else if (char === 'X' || char === '^') {
			pos = newPos;
			// ok
		}
		else {
			assert(false, `Error: ${char}`);
		}

		const state = `${pos.x},${pos.y};${delta.x},${delta.y}`;
		if (states.has(state)) {
			return { infinite: true, visited };
		}
		states.add(state);
	}
}

function solve1(grid: Grid) {
	return analyseWalk(structuredClone(grid)).visited;
}

function solve2(grid: Grid) {
	let result = 0;
	eachRange(grid[0].length, grid.length, (x, y) => {
		if (grid[y][x] !== '.') { return; } // skip starting pos and existing crates.
		const copy = structuredClone(grid)
		copy[y][x] = 'O';
		const flag = analyseWalk(copy);
		if (flag.infinite) result += 1;
	});
	return result;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve1(data));
console.log(solve2(data));

// 16490 too high
// 16439 too high
// 15847 too high