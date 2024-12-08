#!/usr/bin/env tsx

import { assert } from '../common/assert.js';
import { eachRange, find, findAll, inRange, readGridFromFile, type Grid } from '../common/grid.js';

function parse(fname: string) {
	const data = readGridFromFile(fname);
	return data;
}

type Point = { x: number, y: number };

function extractAntennas(grid: Grid) { 
	const result: Record<string, Point[]> = {};
	eachRange(grid[0].length, grid.length, (x, y) => {
		const char = grid[y][x];
		if (char !== '.') {
			if (!(char in result)) {
				result[char] = [];
			}
			result[char].push({x, y});
		}
	});
	return result;
}

function getAntinodes(i: Point, j: Point) {
	const delta = { x: j.x - i.x, y: j.y - i.y };
	return [
		{ x: i.x - delta.x, y: i.y - delta.y },
		{ x: j.x + delta.x, y: j.y + delta.y }
	];
}

function solve1(grid: Grid) {
	const antennas = extractAntennas(grid);

	const antinodes = new Set<string>();

	for (const [k, v] of Object.entries(antennas)) {

		// now take each pair of antennae, and create dead points
		for(let i = 1; i < v.length; i++) {
			for (let j = 0; j < i; ++j) {
				
				// calculate antinodes for pair i,j
				for (const p of getAntinodes(v[i], v[j])) {
					if (inRange(data, p.x, p.y)) {
						antinodes.add(`${p.x},${p.y}`);
					}
				}
			}
		}
	}
	
	return antinodes.size;
}

// function solve2(data: Data) {
// 	let result = 0;
// 	return result;
// }

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve1(data));
// console.log(solve2(data));
