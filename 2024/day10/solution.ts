#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { breadthFirstSearch } from '@amarillion/helixgraph';
import { bfsGenerator } from '@amarillion/helixgraph/lib/pathFinding.js';
import { trackbackNodes } from '@amarillion/helixgraph/lib/pathFinding.js';
import { BaseGrid, TemplateGrid } from '@amarillion/helixgraph/lib/BaseGrid.js';
import { Point } from '../common/point.js';
import { assert } from '../common/assert.js';
import { eachRange } from '../common/grid.js';

type Data = TemplateGrid<Cell>;
class Cell {
	x: number;
	y: number;
	value: number;
	constructor(_x: number, _y: number, _value: number) { this.x = _x; this.y = _y; this.value = _value; }
};

function parse(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' }).split('\n').filter(i => i !== '');
	const grid = new TemplateGrid<Cell>(data[0].length, data.length, (x, y) => new Cell(x, y, Number(data[y][x])));
	return grid;
}

function solve1(grid: Data) {
	// for each 0
	let result = 0;
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
		console.log("Found ", singlePathResult);
		result += singlePathResult;
	});
	return result;
}

// function solve2(data: Data) {
// 	let result = 0;
// 	return result;
// }

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve1(data));
// console.log(solve2(data));
