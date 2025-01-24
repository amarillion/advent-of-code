#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert, notNull } from '../common/assert.js';
import { createGrid, ValueGrid } from '../common/grid.js';
import { IPoint, Point } from '../common/geom/point.js';
import { sum } from '../common/iterableUtils.js';

type Grid = ValueGrid<string>
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

const TRANSFORM = {
	'O': [...'[]'],
	'@': [...'@.'],
	'.': [...'..'],
	'#': [...'##']
}

function transformGrid(grid: Grid) {
	const data = grid.data.map(row => row.flatMap(cell => TRANSFORM[cell]))
	return createGrid(data);
}

function solve2(data: Data) {
	const { grid } = data;
	
	function canPush(pos: IPoint, dir: IPoint) {
		const newPos = Point.plus(pos, dir);
		const char = grid.get(newPos);
		
		if (char === '.') {
			return true;
		}
		
		if (dir.y === 0 && 'O[]'.includes(char)) { // horizontal pushing
			return canPush(newPos, dir);
		}
		
		if (char === '[') {
			const side = { x: newPos.x + 1, y: newPos.y };
			return canPush(newPos, dir) && canPush(side, dir);
		}
		else if (char === ']') {
			const side = { x: newPos.x - 1, y: newPos.y };
			return canPush(newPos, dir) && canPush(side, dir);
		}
		else if (char === 'O') {
			return canPush(newPos, dir);
		}
		return false;
	}

	function doPush(pos: IPoint, dir: IPoint) {
		const char = grid.get(pos);
		
		if ('O[]'.includes(char)) {
			const positions = [ pos ];
			if (dir.y !== 0) {
				if (grid.get(pos) === '[') {
					positions.push({ x: pos.x + 1, y: pos.y });
				}
				else if (grid.get(pos) === ']') {
					positions.push({ x: pos.x - 1, y: pos.y });
				}
			}

			for (const p of positions) {
				const forward = Point.plus(p, dir);
				doPush(forward, dir);
				grid.set(forward, grid.get(p));
				grid.set(p, '.');
			}
		}
	}

	let robot = notNull(grid.find('@'));
	for (const move of data.moves) {
		grid.set(robot, '.');
		const dir = DELTA[move];
		assert(dir);
	
		const newPos = Point.plus(robot, dir);
		const newCell = grid.get(newPos); 
		if ('O[]'.includes(newCell)) {
			if (canPush(robot, dir)) {
				doPush(newPos, dir);
			}
		}
		if (grid.get(newPos) === '.') {
			robot = newPos;
		}
		grid.set(robot, '@');
	}

	return (
		sum(grid.findAll('[').map(({ x, y }) => y * 100 + x)) + 
		sum(grid.findAll('O').map(({ x, y }) => y * 100 + x))
	);
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);

// transform grid before it's modified by the solver
const part2Data = { grid: transformGrid(data.grid), moves: data.moves };

console.log(solve2(data));

console.log(solve2(part2Data));
