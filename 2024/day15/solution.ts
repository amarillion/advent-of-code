#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert, notNull } from '../common/assert.js';
import { createGrid } from '../common/grid.js';
import { IPoint, Point } from '../common/point.js';
import { sum } from '../common/iterableUtils.js';

type Grid = ReturnType<typeof createGrid>;
type Data = { grid: Grid, moves: string[] };

function parse(fname: string) {
	const chunks = readFileSync(fname, { encoding: 'utf-8' }).split('\n\n');
	const grid = createGrid(chunks[0].split('\n').map(line => [...line]));
	const moves = [...chunks[1].split('\n').join('')];
	return { grid, moves }
}

const DELTA = {
	'^': { x: 0, y: -1 },
	'>': { x: 1, y: 0 },
	'v': { x: 0, y: 1 },
	'<': { x: -1, y: 0 },
}
function solve1(data: Data) {
	let result = 0;
	const { grid, moves } = data;
	
	let robot = notNull(grid.find('@'));
	console.log(grid.toString());

	function tryPush(pos: IPoint, dir: IPoint) {
		const newPos = Point.plus(pos, dir);

		if (grid.get(newPos) === 'O') {
			tryPush(newPos, dir);
		}

		if (grid.get(newPos) === '.') {
			// push is ok, swap the values
			grid.set(newPos, grid.get(pos));
			grid.set(pos, '.');
		}
	}

	let i = 0;
	for (const move of moves) {
		grid.set(robot, '.');
		const dir = DELTA[move];
		assert(dir);
		// recursively try to move object at x, y into dir
		const newPos = Point.plus(robot, dir);
		if (grid.get(newPos) === 'O') {
			tryPush(newPos, dir);
		}
		if (grid.get(newPos) === '.') {
			robot = newPos;
		}
		grid.set(robot, '@');
		// console.log(`\nStep: ${++i} Move: ${move}`);
		// console.log(grid.toString());
	}

	console.log(grid.toString());
	return sum(grid.findAll('O').map(({ x, y }) => y * 100 + x));
}

// function solve2(data: Data) {
// 	let result = 0;
// 	return result;
// }

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve1(data));
// console.log(solve2(data));
