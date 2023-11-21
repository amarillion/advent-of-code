#!/usr/bin/env ts-node-esm

import { readFileSync } from 'fs';
import { breadthFirstSearch } from '@amarillion/helixgraph';
import { trackbackNodes } from '@amarillion/helixgraph/lib/pathFinding.js';
import { BaseGrid, TemplateGrid } from '@amarillion/helixgraph/lib/BaseGrid.js';
import { Point } from '../common/point.js';
import { assert } from '../common/assert.js';

function readInput(fname: string) {
	return readFileSync(fname).toString('utf-8');
}

type Mob = {
	pos: Point;
	delta: Point;
	face: string;
}

class Cell {
	mobs: Mob[] = [];
}

class State {
	width: number;
	height: number;
	start: Point;
	exit: Point;
	map: TemplateGrid<Cell>;

	constructor(width: number, height: number) {
		this.width = width;
		this.height = height;
		this.map = new TemplateGrid<Cell>(width, height, () => new Cell());
	}

	toString() {
		let result = '';
		for (let y = 0; y < this.height; ++y) {
			for (let x = 0; x < this.width; ++x) {
				const cell = this.map.get(x, y);
				let face = '.';
				if (cell.mobs.length === 1) {
					face = cell.mobs[0].face;
				}
				else if (cell.mobs.length > 1) {
					face = String(cell.mobs.length);
				}
				result += face;
			}
			result += '\n';
		}
		return result;
	}
	
};

function readInitialState(raw: string): State {
	const lines = raw.split('\n').filter(l => l !== "");
	
	const result = new State(lines[0].length - 2, lines.length - 2);	
	for (let y = 1; y < lines.length - 1; ++y) {
		for (let x = 1; x < lines[y].length - 1; ++x) {
			const pos = new Point(x-1, y-1);
			let delta = null;
			let face = lines[y][x];
			switch (face) {
				case '>': delta = new Point(1, 0); break;
				case '<': delta = new Point(-1, 0); break;
				case '^': delta = new Point(0, -1); break;
				case 'v': delta = new Point(0, 1); break;
			}
			if (delta) { 
				result.map.get(pos.x, pos.y).mobs.push({ pos, delta, face });
			}
		}
	}

	result.start = new Point(0, -1);
	result.exit = new Point(result.width - 1, result.height);

	return result;
}

function update(data: State) {
	const next = new State(data.width, data.height);
	next.start = data.start;
	next.exit = data.exit;

	for (const cell of data.map.eachNode()) {
		for (const mob of cell.mobs) {
			const newPos = new Point(
				(mob.pos.x + mob.delta.x + data.width) % data.width,
				(mob.pos.y + mob.delta.y + data.height) % data.height,
			);
			const copy = { ...mob, pos: newPos };
			next.map.get(newPos.x, newPos.y).mobs.push(copy);
		}
	}
	return next;
}

function countSteps(states: State[], start: string, end: string) {

	const endCoords = end.split(',').map(Number);
	const endPos = new Point(endCoords[0], endCoords[1]);

	function *getAdjacent(pos: string): Iterable<[string, string]> {
		// five possible moves:
		// wait, up, down, left, right
		// in each case, moving to the next slice.
		// check that we're not going out of range
		const coords = pos.split(',').map(Number);
		const point = new Point(coords[0], coords[1]);
		const t = coords[2];

		// auto-vivify new states...
		if (Number(t) + 1 >= states.length) { 
			states[Number(t) + 1] = update(states[t]);
		}
		
		const MOVES = {
			'N': new Point(0, -1), 'E': new Point(1, 0), 'S': new Point(0, 1), 'W': new Point(-1, 0), '-': new Point(0, 0)
		}
		for (const [key, delta] of Object.entries(MOVES)) {
			const newPos = point.plus(delta);
			
			// special case: we can reach exit node...
			if (endPos.equals(newPos)) {
				yield [key, 'exit'];
				continue;
			}
			
			const isStartNode = (newPos.x === 0 && newPos.y === -1);
			const isExitNode = (newPos.x === states[0].width - 1 && newPos.y === states[0].height)
			if (isStartNode || isExitNode) {
			}
			else {
				const inRange = states[0].map.inRange(newPos.x, newPos.y);
				if (!inRange) continue;

				// check for collision:
				if (states[t + 1].map.get(newPos.x, newPos.y).mobs.length > 0) continue;	
			}

			yield [key, [newPos.x, newPos.y, t+1].join(',')];
		}
	}

	// now run dijkstra...
	const prev = breadthFirstSearch(start, 'exit', getAdjacent)
	const result = trackbackNodes(start, 'exit', prev);

	console.log(result);

	return result ? result.length - 1 : 0;
}

function solve(states: State[]) {
	const width = states[0].width;
	const height = states[0].height;
	return countSteps(states, '0,-1,0', `${width-1},${height},*`);
}

function solve2(states: State[]) {
	const width = states[0].width;
	const height = states[0].height;
	
	const s1 = countSteps(states, '0,-1,0', `${width-1},${height},*`);
	const s2 = countSteps(states, `${width-1},${height},${s1}`, '0,-1,*');
	const s3 = countSteps(states, `0,-1,${s1+s2}`, `${width-1},${height},*`);

	console.log({s1, s2, s3});
	return s1 + s2 + s3;
}

// read and parse data
const testData = readInput('test-input');
const initialTestState = readInitialState(testData);

const testStates = [initialTestState, update(initialTestState)];
assert(solve(testStates) === 18);

console.log("PART 2");
assert(solve2(testStates) === 54);

// extract positions and directions of blizzards
// apply dijkstra,
// generate moves ahead as needed


const input = readInput('input');
const initialState = readInitialState(input);
const states = [ initialState, update(initialState) ];
console.log(`${states[0]}`);
console.log(solve(states));
console.log(solve2(states));
