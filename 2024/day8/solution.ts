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

function getAntinodes(grid: Grid, i: Point, j: Point, part2: boolean) {
	const delta = { x: j.x - i.x, y: j.y - i.y };
	if (part2) {
		// extend in both directions until out of range....
		let times = 1;
		let currentPos: Point;
		let currentNeg: Point;
		let result: Point[] = [];
		result.push({ ...i });
		let cont;
		do {
			currentPos = { x: i.x + times * delta.x, y: i.y + times * delta.y };
			currentNeg = { x: i.x - times * delta.x, y: i.y - times * delta.y };
			result.push(currentPos);
			result.push(currentNeg);
			cont = inRange(grid, currentPos.x, currentPos.y) || inRange(grid, currentNeg.x, currentNeg.y);
			times++;
		} while (cont)
		return result;
	}
	else {
		return [
			{ x: i.x - delta.x, y: i.y - delta.y },
			{ x: j.x + delta.x, y: j.y + delta.y }
		];
	}
}

function solve(grid: Grid, part2 = false) {
	const antennas = extractAntennas(grid);

	const antinodes = new Set<string>();

	for (const [k, v] of Object.entries(antennas)) {

		// now take each pair of antennae, and create dead points
		for(let i = 1; i < v.length; i++) {
			for (let j = 0; j < i; ++j) {
				
				// calculate antinodes for pair i,j
				const aa = getAntinodes(grid, v[i], v[j], part2);
				for (const p of aa) {
					if (inRange(data, p.x, p.y)) {
						antinodes.add(`${p.x},${p.y}`);
					}
				}
			}
		}
	}
	
	return antinodes.size;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve(data));
console.log(solve(data, true));
