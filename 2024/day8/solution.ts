#!/usr/bin/env tsx

import { assert } from '../common/assert.js';
import { allPairs } from '../common/combinations.js';
import { readGridFromFile, ValueGrid } from '../common/grid.js';
import { Point } from '../common/point.js';
import { pointRange } from '../common/pointRange.js';

function parse(fname: string) {
	return readGridFromFile(fname);
}

type Grid = ValueGrid<string>;

function extractAntennas(grid: Grid) { 
	const result: Record<string, Point[]> = {};
	pointRange(grid.width, grid.height, (x, y) => {
		const char = grid.data[y][x];
		if (char !== '.') {
			if (!(char in result)) {
				result[char] = [];
			}
			result[char].push(new Point(x, y));
		}
	});
	return Object.values(result);
}

function *getAntinodes(grid: Grid, i: Point, j: Point, part2: boolean) {
	const delta = j.minus(i);
	if (part2) {
		let current = new Point(i.x, i.y);
		while (grid.inRange(current)) {
			yield current;
			current = current.plus(delta);
		}
		current = new Point(j.x, j.y);
		while (grid.inRange(current)) {
			yield current;
			current = current.minus(delta);
		}
	}
	else {
		yield i.minus(delta);
		yield j.plus(delta);
	}
}

function solve(grid: Grid, part2 = false) {
	const uniqueAntinodes = new Set<string>();
	
	for (const v of extractAntennas(grid)) {
		
		// now take each pair of antennae, and create dead points
		for(const pair of allPairs(v)) {

			// calculate antinodes for pair i,j
			const aa = getAntinodes(grid, pair[0], pair[1], part2);
			for (const p of aa) {
				if (grid.inRange(p)) {
					uniqueAntinodes.add(Point.toString(p));
				}
			}
		}
	}
	
	return uniqueAntinodes.size;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve(data));
console.log(solve(data, true));
