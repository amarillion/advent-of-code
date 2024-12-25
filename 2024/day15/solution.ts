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
	const { grid: originalGrid, moves } = data;
	
	const grid = transformGrid(originalGrid);

	console.log(grid.toString());

	let robot = notNull(grid.find('@'));
	console.log(robot);

	function canPush(pos: IPoint, dir: IPoint) {
		const newPos = Point.plus(pos, dir);

		if (grid.get(newPos) === '.') {
			return true;
		}
		
		if (dir.y === 0) { // horizontal pushing
			const char = grid.get(newPos);
			if ('[]'.includes(char)) {
				return canPush(newPos, dir);
			}
			return (char === '.');
		}
		
		if (grid.get(newPos) === '[') {
			const side = { x: newPos.x + 1, y: newPos.y };
			return canPush(newPos, dir) && canPush(side, dir);
		}
		else if (grid.get(newPos) === ']') {
			const side = { x: newPos.x - 1, y: newPos.y };
			return canPush(newPos, dir) && canPush(side, dir);
		}
		return false;
	}

	function doPush(pos: IPoint, dir: IPoint) {
		if (dir.y === 0) { // horizontal pushing
			const newPos = Point.plus(pos, dir);
			if (grid.get(newPos) !== '.') {
				doPush(newPos, dir)
			}
			grid.set(newPos, grid.get(pos));
			grid.set(pos, '.');
			return;
		}
	
		let leftSide = pos, rightSide = pos;
		let isBox = false;
		
		if (grid.get(pos) === '[') {
			isBox = true;
			rightSide = { x: pos.x + 1, y: pos.y };
		}
		else if (grid.get(pos) === ']') {
			isBox = true;
			leftSide = { x: pos.x - 1, y: pos.y };
		}

		if (isBox) {
			const leftForward = Point.plus(leftSide, dir);
			const rightForward = Point.plus(rightSide, dir);
			doPush(leftForward, dir);
			doPush(rightForward, dir);
			grid.set(leftForward, '[');
			grid.set(rightForward, ']');
			grid.set(leftSide, '.');
			grid.set(rightSide, '.');
		}
	}

	let i = 0;
	for (const move of moves) {
		grid.set(robot, '.');
		const dir = DELTA[move];
		assert(dir);
		// recursively try to move object at x, y into dir
		const newPos = Point.plus(robot, dir);
		const newCell = grid.get(newPos); 
		if ('[]'.includes(newCell)) {
			if (canPush(robot, dir)) {
				doPush(newPos, dir);
			}
		}
		if (grid.get(newPos) === '.') {
			robot = newPos;
		}
		grid.set(robot, '@');
		console.log(`\nStep: ${++i} Move: ${move}`);
		console.log(grid.toString());
	}

	return sum(grid.findAll('[').map(({ x, y }) => y * 100 + x));
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
// console.log(solve1(data));
console.log(solve2(data));
