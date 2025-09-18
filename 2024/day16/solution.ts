#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert, notNull } from '../common/assert.js';
import { TemplateGrid } from '@amarillion/helixgraph/lib/BaseGrid.js';
import { find } from '../common/objectGrid.js';
import { IPoint, Point } from '../common/geom/point.js';
import { truthy } from '../common/iterableUtils.js';
import { dijkstraAllShortestPaths } from '../common/dijkstraAllShortestPaths.js';

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

type State = string;
type Edge = string;

// pack state into a string so that it can be used as key
function toState(cell: IPoint, dir: number): State {
	return `${cell.x},${cell.y},${dir}`
}
function toEdge(moves: number, toDir: number): Edge {
	return `${moves},${toDir}`
}
function parseState(grid: TemplateGrid<Cell>, state: State) {
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
function *getAdjacent(grid: TemplateGrid<Cell>, state: State) {
	const { cell, dir } = parseState(grid, state);
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

function solve(grid: Data) {
	// find S and E
	const startCell = notNull(find(grid, cell => cell.char === 'S'));
	const endCell = notNull(find(grid, cell => cell.char === 'E'));

	const startState = toState(startCell, EAST);

	// TODO: Dijkstra should accept Predicate function...
	const endStates = [NORTH, EAST, SOUTH, WEST].map(dir => toState(endCell, dir));

	const prevMap = dijkstraAllShortestPaths<State, Edge>(startState, endStates, state => getAdjacent(grid, state), { getWeight });

	const minCost = Math.min(...endStates.flatMap(endState => prevMap.get(endState)).filter(truthy).map(step => step.cost));
	const minEndState = notNull(endStates.find(e => prevMap.get(e)?.some(f => f.cost === minCost)));

	// TODO: can still be made faster by memoizing, thus skipping duplicate path segments
	function *allShortestPaths(state: State, indent = '') {
		yield state;
		for (const step of prevMap.get(state)) {
			if (step.from) {
				// console.log(`${indent}${step.from} -> ${step.to} ${step.cost}`);
				yield *allShortestPaths(step.from, indent + ' ');
			}
		}
	}
	
	// TODO: use unique filter here...
	const states = [...allShortestPaths(minEndState)];
	return [
		minCost,
		new Set(states.map(state => state.split(',').slice(0,2).join(','))).size
	];
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
console.log(solve(data).join('\n'));
