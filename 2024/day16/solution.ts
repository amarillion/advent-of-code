#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert, notNull } from '../common/assert.js';
import { TemplateGrid } from '@amarillion/helixgraph/lib/BaseGrid.js';
import { find } from '../common/objectGrid.js';
import { dijkstra } from '@amarillion/helixgraph';
import { IPoint, Point } from '../common/point.js';

type Data = TemplateGrid<Cell>;
class Cell {
	x: number;
	y: number;
	char: string;
	constructor(_x: number, _y: number, _char: string) { this.x = _x; this.y = _y; this.char = _char; }
	toString() { 
		return `Cell(${this.x},${this.y} '${this.char}')`;
	}
}

function parse(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' }).split('\n').filter(i => i !== '');

	// TODO: Grid type that tracks <Point, value> instead of <Cell>. Do I need separate Grid classes for reference types and value types?
	return new TemplateGrid<Cell>(data[0].length, data.length, (x, y) => new Cell(x, y, data[y][x]));
}

// TODO: move to common module
const NORTH = 1;
const EAST = 2;
const SOUTH = 4;
const WEST = 8;

type Dir = number;

const DELTAS = {
	[NORTH]: new Point(0, -1),
	[EAST]: new Point(1, 0),
	[SOUTH]: new Point(0, 1),
	[WEST]: new Point(-1, 0)
};
const TURN_CW = {
	[NORTH]: EAST,
	[EAST]: SOUTH,
	[SOUTH]: WEST,
	[WEST]: NORTH
};
const TURN_CCW = {
	[NORTH]: WEST,
	[EAST]: NORTH,
	[SOUTH]: EAST,
	[WEST]: SOUTH
};

function solve1(grid: Data) {
	// find S and E
	const startCell = notNull(find(grid, cell => cell.char === 'S'));
	const endCell = notNull(find(grid, cell => cell.char === 'E'));

	type State = string;
	type Edge = string;

	// pack state into a string so that it can be used as key
	function toState(cell: IPoint, dir: number): State {
		return `${cell.x},${cell.y},${dir}`
	}
	function toEdge(moves: number, toDir: number): Edge {
		return `${moves},${toDir}`
	}
	function parseState(state: State) {
		const fields = state.split(',').map(Number);
		return {
			cell: grid.get(fields[0], fields[1]),
			dir: fields[2]
		}
	}
	function parseEdge(edge: Edge) {
		const fields = edge.split(',').map(Number);
		return {
			moves: fields[0],
			toDir: fields[1]
		}
	}

	const startState = toState(startCell, EAST);

	// TODO: Dijkstra should accept Predicate function...
	const endStates = [NORTH, EAST, SOUTH, WEST].map(dir => toState(endCell, dir));

	function *getAdjacent(state: State) {
		const { cell, dir } = parseState(state);
		// check if a move in the same dir is possible
		const newPos = Point.plus(cell, DELTAS[dir]);
		
		// TODO: inRange and get should accept Point
		if (grid.inRange(newPos.x, newPos.y) && grid.get(newPos.x, newPos.y).char !== '#') {
			yield [ toEdge(1, dir), toState(newPos, dir) ] as [ string, string ];
		}

		// generate turn moves
		yield [ toEdge (0, TURN_CW[dir]), toState(cell, TURN_CW[dir])] as [ string, string ];
		yield [ toEdge (0, TURN_CCW[dir]), toState(cell, TURN_CCW[dir])] as [ string, string ];
	}

	function getWeight(edge: Edge) {
		const { moves, toDir } = parseEdge(edge);
		return moves === 0 ? 1000 : 1;
	}

	// See: https://stackoverflow.com/questions/47632622/typescript-and-filter-boolean
	type Truthy<T> = T extends false | '' | 0 | null | undefined ? never : T; // from lodash
	function truthy<T>(value: T): value is Truthy<T> {
		return !!value;
	}

	const prevMap = dijkstra<State, Edge>(startState, endStates, getAdjacent, { getWeight });
	return Math.min(...endStates.map(endState => prevMap.get(endState)).filter(truthy).map(step => step.cost));
}

// function solve2(data: Data) {
// 	let result = 0;
// 	return result;
// }

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve1(data));
// console.log(solve2(data));
