#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';
import { pointRange } from '../common/pointRange.js';
import { TemplateGrid } from '@amarillion/helixgraph/lib/BaseGrid.js';
import { bfsGenerator } from '@amarillion/helixgraph/lib/pathFinding.js';
import { Point } from '../common/point.js';

type RegionType = {
	id: number;
	area: number;
	char: string;
	permiter: number;
	corners: number;
	start: Point;
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

function solve(grid: Data) {
	let nextRegion = 1;
	const regions: RegionType[] = [];

	// TODO: grid forEach
	pointRange(grid.width, grid.height, (x, y) => {
		const cell = grid.get(x, y);
		if (!cell.region) {
			const region = {
				id: nextRegion++,
				permiter: 0,
				area: 0,
				char: cell.char,
				corners: 0,
				start: new Point(cell.x, cell.y)
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
			}
		}
	});

	pointRange(grid.width, grid.height, (x, y) => {
		const region = grid.get(x, y).region!;
		const pos = new Point(x, y);
		
		let fan = [
			new Point(0, -1),
			new Point(1, -1),
			new Point(1, 0)
		];
		for (let turn = 0; turn < 4; ++turn) {
			const data = fan.map(delta => {
				const newPos = pos.plus(delta);
				return grid.inRange(newPos.x, newPos.y) && grid.get(newPos.x, newPos.y).region === region;
			});
			if (!data[0] && !data[2]) {
				/* Outside corner: ?.?
                                   ?X.
                                   ???
				*/
				region.corners++;
			}
			if (data[0] && !data[1] && data[2]) {
				/* Inside corner: ?X.
                                  ?XX
                                  ???
				*/
				region.corners++;
			}

			fan = fan.map(delta => delta.rotate(90));
		}
	});

	// for each region
	let result = [0, 0];
	for (const region of regions) {
		result[0] += (region.area * region.permiter);
		result[1] += (region.area * region.corners);
	}
	return result;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve(data).join('\n'));
