#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';
import { eachRange, Grid, inRange, readGridFromFileEx } from '../common/grid.js';
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


const NORTH = 1;
const EAST = 2;
const SOUTH = 4;
const WEST = 8;

const DELTAS = {
	[NORTH]: new Point(0, -1),
	[EAST]: new Point(1, 0),
	[SOUTH]: new Point(0, 1),
	[WEST]: new Point(-1, 0)
};
const TURN = {
	[NORTH]: EAST,
	[EAST]: SOUTH,
	[SOUTH]: WEST,
	[WEST]: NORTH
};

function solve1(grid: Data) {
	let nextRegion = 1;
	const regions: RegionType[] = [];

	eachRange(grid.width, grid.height, (x, y) => {
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

	eachRange(grid.width, grid.height, (x, y) => {
		const data: boolean[] = [];	
		const region = grid.get(x, y).region!;
		for (const [dx, dy] of [
			[0, -1],
			[1, -1],
			[1, 0],
			[1, 1],
			[0, 1],
			[-1, 1],
			[-1, 0],
			[-1, -1]
		]) {
			const newPos = new Point(x + dx, y + dy);
			data.push(grid.inRange(newPos.x, newPos.y) && grid.get(newPos.x, newPos.y).region === region);
		}
		const prev = region.corners;
		if (!data[0] && /* !data[1] && */ !data[2]) {
			region.corners++;
		}
		if (data[0] && !data[1] && data[2]) {
			region.corners++;
		}
		if (!data[2] && /* !data[3] && */ !data[4]) {
			region.corners++;
		}
		if (data[2] && !data[3] && data[4]) {
			region.corners++;
		}
		if (!data[4] && /* !data[5] && */ !data[6]) {
			region.corners++;
		}
		if (data[4] && !data[5] && data[6]) {
			region.corners++;
		}
		if (!data[6] && /* !data[7] && */ !data[0]) {
			region.corners++;
		}
		if (data[6] && !data[7] && data[0]) {
			region.corners++;
		}
		if (region.corners !== prev) {
			console.log(`Corners: ${region.corners-prev} ${region.char}: ${x},${y} ${data.map(i => i ? 1 : 0).join('')}`);
		}
	});
	function wallhugger(region: RegionType) {
		let pos = region.start;
		const corners = new Set<string>();
		const states = new Set<string>();
		let dir = SOUTH;
		while(true) {
			const forwardPos = Point.plus(pos, DELTAS[dir]);
			const rightPos = Point.plus(pos, DELTAS[TURN[dir]]);
			const leftPos = Point.plus(pos, DELTAS[TURN[TURN[TURN[dir]]]]);

			const forwardCell = (grid.inRange(forwardPos.x, forwardPos.y) && grid.get(forwardPos.x, forwardPos.y).region === region);
			const rightCell = (grid.inRange(rightPos.x, rightPos.y) && grid.get(rightPos.x, rightPos.y).region === region);

			if (rightCell) {
				// turn right
				corners.add(`${pos.x},${pos.y};${dir}`);
				pos = rightPos;
				dir = TURN[dir];
			}
			else if (forwardCell) {
				// move forward
				pos = forwardPos;
			}
			else {
				// turn left
				corners.add(`${pos.x},${pos.y};${dir}`);
				dir = TURN[TURN[TURN[dir]]];
			}

			const state = `${pos.x},${pos.y}-${dir}`;
			if (states.has(state)) {
				break;
			}
			else {
				states.add(state);
			}
		}
		console.log(corners);
		return corners.size;
	}

	// for (const region of regions) {
	// 	region.corners = wallhugger(region);
	// }

	// for each region
	let result = 0;
	let result2 = 0;
	for (const region of regions) {
		console.log(region);
		result += (region.area * region.permiter);
		result2 += (region.area * region.corners);
	}
	return [result, result2];
}

// function solve2(data: Data) {
// 	let result = 0;
// 	return result;
// }

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve1(data));
// console.log(solve2(data));

// 886164 too low
// test-input4 wrong...