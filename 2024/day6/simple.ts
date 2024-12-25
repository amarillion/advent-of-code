#!/usr/bin/env tsx

import { assert } from '../common/assert.js';
import { createGrid, find, findAll, inRange, readGridFromFile, type Grid } from '../common/grid.js';

function analyseWalk(grid: Grid) {
	let visited = 1;
	let pos = grid.find('^');
	let delta = { x: 0, y : -1 };
	const states = new Set<string>()
	while(true) {
		assert(pos);
		const newPos = { x: pos.x + delta.x, y: pos.y + delta.y };
		if (!grid.inRange(newPos)) {
			return {
				infinite: false, visited, grid
			};
		}

		const char = grid.get(newPos);
		if (char === '#' || char === 'O') {
			// rotate 90 degrees
			delta = { x: -delta.y, y: delta.x };
		}
		else if (char === '.') {
			pos = newPos;
			grid.set(pos, 'X');
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
	return analyseWalk(createGrid(structuredClone(grid.data))).visited;
}

function solve2(grid: Grid) {
	let result = 0;
	const pointsToCheck = analyseWalk(createGrid(structuredClone(grid.data))).grid.findAll('X');
	for(const {x, y} of pointsToCheck) {
		if (grid.get({ x, y }) !== '.') { return; } // skip starting pos and existing crates.
		const copy = createGrid(structuredClone(grid.data))
		copy.set({ x, y }, 'O');
		const flag = analyseWalk(copy);
		if (flag.infinite) result += 1;
	};
	return result;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = readGridFromFile(process.argv[2]);
console.log(solve1(data));
console.log(solve2(data));