#!/usr/bin/env tsx
import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';
import { Point, IPoint } from '../common/point.js';
import { TemplateGrid } from '../common/BaseGrid.js';

type Grid = TemplateGrid<string>;

enum Dir {
	E = 1, S = 2, W = 4, N = 8
}

function readGrid(lines: string[]) {
	const height = lines.length;
	const width = lines[0].length;

	const grid = new TemplateGrid<string>(width, height, () => ' ');
	for(let y = 0; y < height; ++y) {
		for(let x = 0; x < width; ++x) {
			grid.set(x, y, lines[y][x]);
		}
	}
	return grid;
}

function parse(fname: string) {
	let lines = readFileSync(fname).toString('utf-8').split('\n').filter(s => s !== '');
	return readGrid(lines);
}

const DELTA = new Map<Dir, Point>([
	[Dir.E, new Point(1, 0)], 
	[Dir.S, new Point(0, 1)], 
	[Dir.W, new Point(-1, 0)], 
	[Dir.N, new Point(0, -1)]
]);

const SHORT = new Map<Dir, string>([
	[ Dir.E, '>' ],
	[ Dir.S, 'v' ],
	[ Dir.W, '<' ],
	[ Dir.N, '^' ],
]);

function *getAdjacent1(grid: Grid, pos: Point): Iterable<[Dir, Point]> {
	for(const dir of [Dir.E, Dir.S, Dir.W, Dir.N]) {
		const np = Point.plus(pos, DELTA.get(dir));
		if (grid.inRange(np.x, np.y)) {
			const cell = grid.get(np.x, np.y);
			if (cell === '.' || cell === SHORT.get(dir)) {
				yield [ dir, np ];
			}
		}
	}
}

function *getAdjacent2(grid: Grid, pos: Point): Iterable<[Dir, Point]> {
	for(const dir of [Dir.E, Dir.S, Dir.W, Dir.N]) {
		const np = Point.plus(pos, DELTA.get(dir));
		if (grid.inRange(np.x, np.y)) {
			const cell = grid.get(np.x, np.y);
			if (cell !== '#') {
				yield [ dir, np ];
			}
		}
	}
}

type Edge = {
	src: IPoint;
	dest: IPoint;
	dir: Dir;
	weight: number;
}

type Graph = Map<string, Map<Dir, Edge> >

function simplify(AdjacencyFunc: (p: IPoint) => Iterable<[Dir, IPoint]>, source: Point, end: Point) : Graph {

	const result = new Map<string, Map<Dir, Edge>>();
	const open: IPoint[] = [ source, end ];
	const isOpened = new Set([String(source), String(end)]);

	while(open.length > 0) {
		const current = open.shift();

		// console.log(`Simplify: examining ${current}`);
		for(const edge of AdjacencyFunc(current)) {
			const dir = edge[0];
			let next = edge[1];
			// console.log(`Following: ${dir}`);

			// follow as long as possible
			let weight = 1;
			let numLinks: number;
			const visited = new Set([ Point.toString(current) ]);
			while(true) {
				// console.log(`Weight ${weight} next ${next}`);
				visited.add(Point.toString(next));
				const adjacents = [ ... AdjacencyFunc(next) ];
				// console.log(adjacents);
				
				numLinks = adjacents.length;
				if (numLinks != 2) break;
				
				if (visited.has(Point.toString(adjacents[0][1]))) { 
					next = adjacents[1][1];
				} else { 
					next = adjacents[0][1]; 
				}
				weight++;
			}
			const dest = { ...next };

			// create two new edges
			const currentKey = Point.toString(current);
			if (!result.has(currentKey)) { result.set(currentKey, new Map<Dir, Edge>()); }
			result.get(currentKey).set(dir, { src: current, dest, dir, weight });

			if (!isOpened.has(Point.toString(dest))) {
				open.push(dest);
				isOpened.add(Point.toString(dest));
			}
		}
		// console.log(result);
	}

	return result;
}

function longestPath(
	AdjacencyFunc : (p: IPoint) => Iterable<[Dir, IPoint]>, 
	WeightFunc: (p: IPoint, dir: Dir) => number, 
	start: Point, 
	end: Point
) {

	const path: [Dir, IPoint][] = [];
	
	const visited = new Set<string>;
	let len = 0;
	let maxLen = 0;
	let current: IPoint = start;
	let prevChoice = 0;
	let lengths: number[] = [];

	while(true) {
		// console.log(`Currently at #${len}: ${current}`);

		// forward
		const options = [ ...AdjacencyFunc(current) ];
		visited.add(Point.toString(current));
		let found = false;
		
		// It's important that options are processed in ascending order of direction
		// to make comparison with prevChoice work.
		options.sort((a, b) => a[0] - b[0]);

		for(const option of options) {
			if (option[0] <= prevChoice) continue;

			// pick first viable option...
			if (!visited.has(Point.toString(option[1]))) {
				path.push(option);
				found = true;
				break;
			}
		}

		if (found) {
			// console.log(`Moving forward ${path[path.length-1][0]}, ${path[path.length-1][1]}`);
			len += WeightFunc(current, path[path.length-1][0]);
			current = path[path.length-1][1];
			prevChoice = 0;

			if (Point.equals(current, end)) {
				// save result
				lengths.push(len);
				// console.log(`Reached end, added another path: ${len}`);
				if (len > maxLen) { maxLen = len; }
			}
		}
		
		if (!found || Point.equals(current, end)) {
			// backtrack one step.
			const prevStep = path[path.length - 1];
			visited.delete(Point.toString(prevStep[1]));
			const prevDir = prevStep[0];
			prevChoice = prevStep[0];
			path.pop();

			if (path.length === 0) {
				// backtracked all the way to start...
				break;
			}

			current = path[path.length-1][1];
			len -= WeightFunc(current, prevDir);
			// console.log(`Backtracking to ${current} prevChoice ${prevChoice}`);
		}

	}

	return maxLen;
}

function solve1(grid: Grid) {
	const start = new Point(1, 0);
	const end = new Point(grid.width - 2, grid.height - 1);

	const result = longestPath(
		(p: Point) => getAdjacent1(grid, p), 
		(p: Point, d: Dir) => 1, 
		start, 
		end
	);
	return result;
}

function solve2(grid: Grid) {
	const start = new Point(1, 0);
	const end = new Point(grid.width - 2, grid.height - 1);

	const graph = simplify((p: Point) => getAdjacent2(grid, p), start, end);
	
	// let str = ''
	// for(const [k, v] of graph.entries()) {
	// 	str += `${k} =>`;
	// 	for(const e of v.values()) {
	// 		str += ` ${e.dir} to ${Point.toString(e.dest)} in ${e.weight} steps;`;
	// 	}
	// 	str += '\n';
	// }
	// console.log(str);

	// pre-calculate adjacency data
	const adjacent = new Map<string, [Dir, IPoint][]>();
	for(const [k, v] of graph.entries()) {
		adjacent.set(k, []);
		for(const e of v.values()) {
			adjacent.get(k).push([e.dir, e.dest]);
		}
	}

	const result = longestPath(
		(p: Point) => adjacent.get(Point.toString(p)),
		(p: Point, d: Dir) => graph.get(Point.toString(p)).get(d).weight,
		start, 
		end
	);
	return result;
}

assert(process.argv.length === 3, "Expected argument: input file");
const fname = process.argv[2];
const data = parse(fname);
console.log(solve1(data));
console.log(solve2(data));
