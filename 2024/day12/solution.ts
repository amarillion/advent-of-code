#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';
import { eachRange, Grid, readGridFromFileEx } from '../common/grid.js';
import { TemplateGrid } from '@amarillion/helixgraph/lib/BaseGrid.js';
import { bfsGenerator } from '@amarillion/helixgraph/lib/pathFinding.js';

type RegionType = {
	id: number;
	area: number;
	char: string;
	permiter: number;
}

type Data = TemplateGrid<Cell>;
class Cell {
	x: number;
	y: number;
	char: string;
	region: RegionType|null;
	constructor(_x: number, _y: number, _char: string) { this.x = _x; this.y = _y; this.char = _char; this.region = null; }
}

function parse(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' }).split('\n').filter(i => i !== '');

	// TODO: Grid type that tracks <Point, value> instead of <Cell>. Do I need separate Grid classes for reference types and value types?
	return new TemplateGrid<Cell>(data[0].length, data.length, (x, y) => new Cell(x, y, data[y][x]));
}

function solve1(grid: Data) {
	let result = 0;
	let nextRegion = 1;
	const regions: RegionType[] = [];

	eachRange(grid.width, grid.height, (x, y) => {
		const cell = grid.get(x, y);
		if (!cell.region) {
			const region = {
				id: nextRegion++,
				permiter: 0,
				area: 0,
				char: cell.char
			}
			regions.push(region);
			nextRegion++;
			for (const regionCell of bfsGenerator(cell, function *(c) {
				for (const [dir, other] of grid.getAdjacent(c)) {
					if (other.char === c.char) {
						yield [dir, other];
					}
				}
			})) {
				let localPerimiter = 4;
				for (const [, other] of grid.getAdjacent(regionCell)) {
					if (other.char === region.char) {
						localPerimiter--;
					}
				}
				regionCell.region = region;
				region.area++;
				region.permiter += localPerimiter;
				// TODO calculate perimiter
			}
		}
	});

	// for each region
	for (const region of regions) {
		console.log(region);
		result += (region.area * region.permiter);
	}
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
