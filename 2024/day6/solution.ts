#!/usr/bin/env tsx

import { assert } from '../common/assert.js';
import { eachRange, find, findAll, inRange, readGridFromFileEx, type Grid } from '../common/grid.js';
import { DefaultMap } from '../common/DefaultMap.js'
import { Point } from '../common/point.js';

const NORTH = 1;
const EAST = 2;
const SOUTH = 4;
const WEST = 8;
const HORIZONTAL = 10;
const VERTICAL = 5;

type Dir = number;

const DELTAS = {
	[NORTH]: new Point(0, -1),
	[EAST]: new Point(1, 0),
	[SOUTH]: new Point(0, 1),
	[WEST]: new Point(-1, 0)
};
const CARDINAL = {
	[NORTH]: VERTICAL,
	[EAST]: HORIZONTAL,
	[SOUTH]: VERTICAL,
	[WEST]: HORIZONTAL
}
const TURN = {
	[NORTH]: EAST,
	[EAST]: SOUTH,
	[SOUTH]: WEST,
	[WEST]: NORTH
};

function findNext(obstacles: number[], pos: number, reverse: boolean) {
	if (reverse) {
		return obstacles.find(i => pos > i);
	}
	else {
		return obstacles.find(i => pos < i);
	}
}

function *iteration(start: Point, barrierMap: { get: (dir: number) => { get: (primary: number ) => number[] } }, grid: Grid) {
	let pos = start;
	let dir = NORTH;
	while(true) {
		const delta = DELTAS[dir];
		const [ primary, secondary, dd ] = CARDINAL[dir] === VERTICAL ? [ pos.x, pos.y, delta.y ] : [ pos.y, pos.x, delta.x ];
		const obstacles = barrierMap.get(dir).get(primary);
		const obstacle = findNext(obstacles, secondary, dd < 0)
		
		if (obstacle === undefined) {
			// leaving map
			let exitPos: Point;
			switch(dir) {
				case NORTH: exitPos = new Point(pos.x, 0); break;
				case EAST: exitPos = new Point(grid[0].length - 1, pos.y); break;
				case SOUTH: exitPos = new Point(pos.x, grid.length - 1); break;
				default: case WEST: exitPos = new Point(0, pos.y); break;
			}
			yield { dir, pos: exitPos, done: true };
			return;
		}

		const newPos = (CARDINAL[dir] === VERTICAL ? new Point(primary, obstacle) : new Point(obstacle, primary)).minus(delta);
		yield { dir, pos: newPos, done: false }

		pos = newPos;
		dir = TURN[dir];
	}
}

function *stepWise(grid: Grid, barrierMap: DefaultMap<Dir, DefaultMap<number, number[]>>, start: Point) {
	let current = start;
	yield current;
	for (const { dir, pos } of iteration(start, barrierMap, grid)) {
		const delta = DELTAS[dir];
		while (!current.equals(pos)) {
			current = current.plus(delta);
			yield current;
		}
	}
}

//TODO: merge with takeUnique from puzzles prep
function uniqueList(generator: Generator<Point>) {
	let visitedSet = new Set<string>();
	let visited: Point[] = [];
	for (const current of generator) {
		if (!visitedSet.has(current.toString())) {
			visitedSet.add(current.toString());
			visited.push(current);
		}
	}
	return visited;
}

function isInfinite(grid: Grid, extraBarrier: Point, barrierMap: DefaultMap<Dir, DefaultMap<number, number[]>>, start: Point) {
	const states = new Set<string>();
	
	const proxyMap = {
		get: (dir: number) => ({
			get: (primary: number) => {
				const obstacles = barrierMap.get(dir).get(primary); 
				let result = obstacles;
				if (dir === NORTH && primary === extraBarrier.x) {
					result = [...obstacles, extraBarrier.y ];
					result.sort((a,b) => b - a);
				}
				else if (dir === EAST && primary === extraBarrier.y) {
					result = [...obstacles, extraBarrier.x ];
					result.sort((a,b) => a - b);
				}
				else if (dir === SOUTH && primary === extraBarrier.x) {
					result = [...obstacles, extraBarrier.y ];
					result.sort((a,b) => a - b);
				}
				else if (dir === WEST && primary === extraBarrier.y) {
					result = [...obstacles, extraBarrier.x ];
					result.sort((a,b) => b - a);
				}
				return result;
			}
		})
	};

	for (const { dir, pos } of iteration(start, proxyMap, grid)) {
		const state = `${pos.x},${pos.y};${dir}`;
		if (states.has(state)) {
			return true;
		}
		states.add(state);
	}
	return false;
}

function getBarriers(grid: Grid) {
	const barrierMap = new DefaultMap<Dir, DefaultMap<number, number[]>>(
		() => new DefaultMap<number, number[]>([])
	);
	let start: Point|undefined;
	eachRange(grid[0].length, grid.length, (x, y) => {
		const char = grid[y][x];
		if (char === '#') {
			barrierMap.get(NORTH).get(x).unshift(y)
			barrierMap.get(EAST).get(y).push(x)
			barrierMap.get(SOUTH).get(x).push(y)
			barrierMap.get(WEST).get(y).unshift(x)
		}
		if (char === '^') {
			start = new Point(x, y);
		}
	});
	assert(start);
	return { barrierMap, start }
} 

function solve1(grid: Grid) {
	const { barrierMap, start } = getBarriers(grid);
	const visited = uniqueList(stepWise(grid, barrierMap, start));
	return visited.length;
}

function solve2(grid: Grid) {
	let result = 0;
	const { barrierMap, start } = getBarriers(grid);
	const pointsToCheck = uniqueList(stepWise(grid, barrierMap, start));
	for(const p of pointsToCheck) {
		if (grid[p.y][p.x] !== '.') { continue; } // skip starting pos.
		const flag = isInfinite(grid, p, barrierMap, start);
		if (flag) result += 1;
	};
	return result;
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const grid = readGridFromFileEx(process.argv[2]);
console.log(solve1(grid.data));
console.log(solve2(grid.data));