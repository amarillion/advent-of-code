#!/usr/bin/env ts-node-esm

import { readFileSync } from 'fs';
import { SparseGrid } from '../common/sparsegrid.js';
import { Point } from '../common/point.js';
import { assert } from '../common/assert.js';

type Mob = {
	pos: Point;
	dest?: Point;
}

function loadGrid(fname: string) {
	let raw = readFileSync(fname).toString('utf-8');
	let lines = raw.split('\n');
	const width = lines[0].length;
	const height = lines.length;
	
	const mobs: Mob[] = [];
	const grid = new SparseGrid<string>();

	for (let y = 0; y < height; ++y) {
		for (let x = 0; x < width; ++x) {
			if (lines[y][x] === '#') {
				const pos = new Point(x, y);
				mobs.push({pos});
				grid.set(pos, '#');
			}
		}
	}

	return { mobs, grid };
}

function drawGrid(grid: SparseGrid<string>) {
	let result = '';
	for (let y = grid.minY; y <= grid.maxY; ++y) {
		for (let x = grid.minX; x <= grid.maxX; ++x) {
			result += grid.get(new Point(x, y), '.');
		}
		result += '\n';
	}
	return result;
}

function step(grid: SparseGrid<string>, mobs: Mob[], stepCount: number) {
	const collisionMap = new SparseGrid<number>();
	const adjacent = {
		N: new Point(0, -1), 
		NE: new Point(1, -1),
		E: new Point(1, 0),
		SE: new Point(1, 1),
		S: new Point(0, 1),
		SW: new Point(-1, 1),
		W: new Point(-1, 0),
		NW: new Point(-1, -1)
	}

	const options = [
		[ 'N', 'NE', 'NW' ],
		[ 'S', 'SE', 'SW' ],
		[ 'W', 'NW', 'SW' ],
		[ 'E', 'NE', 'SE' ]
	]

	const DIRNAMES = "NSWE";
	console.log(`Moving: ${DIRNAMES[stepCount % 4]}`);

	for (const mob of mobs) {
		mob.dest = mob.pos;
		const data : Record<string, boolean> = {};
		let count = 0;
		for (const [key, delta] of Object.entries(adjacent)) {
			const newPos = mob.pos.plus(delta)
			const flag = grid.has(newPos);
			data[key] = flag;
			if (flag) count++;
		}

		if (count === 0) {
			// stay in place
		}
		else {
			for (let i = 0; i < 4; ++i) {
				const idx = (i + stepCount) % options.length;
				const option = options[idx];
				const newPos = mob.pos.plus(adjacent[option[0]]); 
				// console.log(`Mob ${mob.pos} is considering ${DIRNAMES[idx]} -  checking ${newPos} and ${mob.pos.plus(option[1])} and ${mob.pos.plus(option[2])}}`)
				if (!data[option[0]] && 
					!data[option[1]] && 
					!data[option[2]]) {
						// console.log ("OK!");
						mob.dest = newPos;
						collisionMap.set(newPos, collisionMap.get(newPos, 0) + 1);
						break;
					}
			}
		}
	}
	
	const newGrid = new SparseGrid<string>();
	for (const mob of mobs) {
		// console.log(`Mob at ${mob.pos} wants to move to ${mob.dest}, target: ${collisionMap.get(mob.dest)}`);
		if (collisionMap.get(mob.dest) < 2) {
			mob.pos = mob.dest;
			mob.dest = null;
		}
		newGrid.set(mob.pos, '#');
	}
	return newGrid;
}

function solve(fname: string) {

	let { grid, mobs } = loadGrid(fname);
	console.log(drawGrid(grid));
	for (let i = 0; i < 10; ++i) {
		grid = step(grid, mobs, i);
		console.log(`After round ${i+1}`);
		console.log(drawGrid(grid));

	}

	// const result = drawGrid(grid);
	const result = ((grid.maxX - grid.minX + 1) * (grid.maxY - grid.minY + 1)) - mobs.length;
	return result;
}


assert(solve('test-input') === 110);
console.log(solve('input')); // 3920 -> correct