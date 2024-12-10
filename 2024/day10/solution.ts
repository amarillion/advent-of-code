#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { bfsGenerator } from '@amarillion/helixgraph/lib/pathFinding.js';
import { TemplateGrid } from '@amarillion/helixgraph/lib/BaseGrid.js';
import { assert } from '../common/assert.js';
import { eachRange } from '../common/grid.js';

type Data = TemplateGrid<Cell>;
class Cell {
	x: number;
	y: number;
	value: number;
	constructor(_x: number, _y: number, _value: number) { this.x = _x; this.y = _y; this.value = _value; }
}

function parse(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' }).split('\n').filter(i => i !== '');

	// TODO: Grid type that tracks <Point, value> instead of <Cell>. Do I need separate Grid classes for reference types and value types?
	return new TemplateGrid<Cell>(data[0].length, data.length, (x, y) => new Cell(x, y, Number(data[y][x])));
}

function solve1(grid: Data) {
	// for each 0
	let result = 0;

	// TODO: grid.forEach
	eachRange(grid.width, grid.height, (x, y) => {
		let singlePathResult = 0;
		if (grid.get(x, y).value === 0) {
			// perform a bfs search
			for (const visit of bfsGenerator(grid.get(x, y), function *(base: Cell) {
				for (const [dir, other] of grid.getAdjacent(base)) {
					if (other.value === base.value + 1) {
						yield [dir, other];
					}
				}
			})) {
				if (visit.value === 9) {
					singlePathResult++;
				}
			}
		}
		result += singlePathResult;
	});
	return result;
}

function solve2(grid: Data) {
	let result = 0;

	// TODO: grid.forEach
	eachRange(grid.width, grid.height, (x, y) => {
		// for each 0
		if (grid.get(x, y).value === 0) {
			const source = grid.get(x, y);
			function countPathsRecursively(base: Cell) {
				let result = 0;
				for (const [, other] of grid.getAdjacent(base)) {
					if (other.value === base.value + 1) {
						if (other.value === 9) {
							result++;
						}
						else {
							result += countPathsRecursively(other);
						}
					}
				}
				return result;
			}
			result += countPathsRecursively(source);
		}
	});
	return result;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve1(data));
console.log(solve2(data));
