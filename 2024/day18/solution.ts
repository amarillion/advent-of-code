#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';
import { IPoint, Point } from '../common/point.js';
import { truthy } from '../common/iterableUtils.js';
import { breadthFirstSearch } from '@amarillion/helixgraph';
import { trackbackNodes } from '@amarillion/helixgraph/lib/pathFinding.js';
import { createEmptyGrid } from '../common/grid.js';

type Data = IPoint[];

function parse(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' })
		.split('\n').filter(truthy)
		.map(line => { 
			const [x,y] = line.split(',').map(Number); 
			return { x, y };
		});
	return data;
}

function solve1(data: Data, size: number) {
	const toIndex = (p: IPoint) => p.x + size * p.y;
	const fromIndex = (idx: number) => ({ x: idx % size, y : Math.floor(idx / size) });
	const inRange = (p: IPoint) => (p.x >= 0 && p.y >= 0 && p.x < size && p.y < size);

	// const grid = createEmptyGrid({ x: size, y: size }, () => '.');
	// data.forEach(p => grid.set(p, '#'));
	// console.log(grid.toString());

	const blocked = new Set(data.map(toIndex));

	const source = toIndex({ x: 0, y: 0});
	const dest = toIndex({ x: size-1, y: size-1 });
	const prevMap = breadthFirstSearch(
		source,
		dest,
		function *(from: number) {
			let delta = new Point(1, 0);
			const p = fromIndex(from);
			for (let i = 0; i < 4; ++i) {
				const np = delta.plus(p);
				if (inRange(np)) {
					const to = toIndex(np);
					if (!blocked.has(to)) {
						yield [i, to];
					}
				}
				delta = delta.rotate(90);
			}
		}
	)
	const path = trackbackNodes(source, dest, prevMap);
	return path ? path.length - 1 : 0;
}

function solve2(data: Data, size: number) {
	// brute force method: repeatedly invoke bfs with longer lists of obstacles.
	for (let i = 1; i < data.length; ++i) {
		const result = solve1(data.slice(0, i), size);
		// console.log(`#${i}: ${data[i].x},${data[i].y} ${result}`)
		if (result === 0) {
			// first blocking block
			const p = data[i-1];
			return `${p.x},${p.y}`;
		}
	}
	return 'not found';
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const fname = process.argv[2];
const data = parse(fname);
const size = fname.startsWith('test') ? 7 : 71;
const num = fname.startsWith('test') ? 12 : 1024;
console.log(solve1(data.slice(0, num), size));
console.log(solve2(data, size));
