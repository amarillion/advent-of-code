#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert, notNull } from '../common/assert.js';
import { TemplateGrid } from '@amarillion/helixgraph/lib/BaseGrid.js';
import { find } from '../common/objectGrid.js';
import { IPoint, Point } from '../common/geom/point.js';
import { AdjacencyFunc, Step, WeightFunc } from '@amarillion/helixgraph/lib/definitions.js';
import { DefaultMap } from '../common/DefaultMap.js';
import { truthy } from '../common/iterableUtils.js';

function spliceLowest<T>(queue: Set<T>, comparator: (a: T, b: T) => number) {
	let minElt: T | null = null;
	for (const elt of queue) {
		if (minElt === null || comparator(elt, minElt) < 0) {
			minElt = elt;
		}
	}
	if (minElt) queue.delete(minElt);
	return minElt;
}

function toSet<T>(value: T[] | T) {
	if (Array.isArray(value)) {
		return new Set(value);
	}
	else {
		return new Set([ value ]);
	}
}

/**
 * Given a weighted graph, find all paths from one source to one or more destinations
 * 
 * This alternative version can find _all_ paths with the lowest cost.
 * Instead of returning a map of steps, it returns a multimap with all possible steps that can reach a certain node with the same cost.
 * 
 * @param {*} source
 * @param {*} dest - the search destination node, or an array of destinations that must all be found
 * @param {*} getAdjacent
 * @param {*}
 *
 * @returns Map(to, { edge, from[], to, cost }[])
 */
//TODO: should this alternative dijkstra function be added back to HelixGraph somehow?
export function dijkstraEx<N, E>(source: N, dest: N | N[], getAdjacent: AdjacencyFunc<N, E>,
	{
		maxIterations = 0,
		getWeight = () => 1,
	}: {
		maxIterations?: number,
		getWeight?: WeightFunc<N, E>,
	} = {}
) {
	// Mark all nodes unvisited. Create a set of all the unvisited nodes called the unvisited set.
	// Assign to every node a tentative distance value: set it to zero for our initial node and to infinity for all other nodes. Set the initial node as current.[13]
	const dist = new Map<N, number>();
	const visited = new Set<N>();
	const prev = new DefaultMap<N, Step<N, E>[]>([]);
	const remain = toSet(dest);
	
	// TODO: more efficient to use a priority queue here
	const open = new Set<N>();

	open.add(source);
	dist.set(source, 0);

	let i = maxIterations;
	while (open.size) {
		i--; // 0 -> -1 means Infinite.
		if (i === 0) break;

		// extract the element from Q with the lowest dist. Open is modified in-place.
		// TODO: optionally use PriorityQueue
		// O(N^2) like this, O(log N) with priority queue. But in my tests, priority queues only start pulling ahead in large graphs
		const current = spliceLowest(open, (a, b) => dist.get(a)! - dist.get(b)!)!;

		// check adjacents, calculate distance, or  - if it already had one - check if new path is shorter
		for (const [ edge, sibling ] of getAdjacent(current)) {
			if (!(visited.has(sibling))) {
				const alt = dist.get(current)! + getWeight(edge, current);
				
				// any node that is !visited and has a distance assigned should be in open set.
				open.add (sibling); // may be already in there, that is OK.

				const oldDist = dist.get(sibling) || Infinity;

				if (alt < oldDist) {
					// set or update distance
					dist.set(sibling, alt);
					// build back-tracking map
					prev.set(sibling, [{ edge, from: current, to: sibling, cost: alt }]);
				}
				// alternative path with equal cost
				else if (alt === oldDist) {
					prev.update(sibling, val => { val.push({ edge, from: current, to: sibling, cost: alt }); return val });
				}
			}
		}

		// A visited node will never be checked again.
		visited.add(current);

		if (remain.has(current)) {
			remain.delete(current);
			if (remain.size === 0) break;
		}
	}

	return prev;
}

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

	const prevMap = dijkstraEx<State, Edge>(startState, endStates, state => getAdjacent(grid, state), { getWeight });

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
