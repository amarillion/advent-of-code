#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';
import { find, findAll, inRange, readGridFromFile, type Grid } from '../common/grid.js';

function analyseWalk(grid: Grid) {
	let visited = 1;
	let pos = find(grid, '^');
	let delta = { x: 0, y : -1 };
	const states = new Set<string>()
	while(true) {
		assert(pos);
		const newPos = { x: pos.x + delta.x, y: pos.y + delta.y };
		if (!inRange(grid, newPos.x, newPos.y)) {
			return {
				infinite: false, visited, grid
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
			return { infinite: true, visited, grid };
		}
		states.add(state);
	}
}

function solve1(grid: Grid) {
	return analyseWalk(structuredClone(grid)).visited;
}

function solve2(grid: Grid) {
	let result = 0;
	const pointsToCheck = findAll(analyseWalk(structuredClone(grid)).grid, 'X');
	for(const {x, y} of pointsToCheck) {
		if (grid[y][x] !== '.') { return; } // skip starting pos and existing crates.
		const copy = structuredClone(grid)
		copy[y][x] = 'O';
		const flag = analyseWalk(copy);
		if (flag.infinite) result += 1;
	};
	return result;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = readGridFromFile(process.argv[2]);
console.log(solve1(data));
console.log(solve2(data));