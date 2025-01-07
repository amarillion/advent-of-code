#!/usr/bin/env tsx

import { readFileSync } from 'fs';
import { assert } from '../common/assert.js';
import { IPoint, Point } from '../common/point.js';
import { DefaultMap } from '../common/DefaultMap.js';
// import { createEmptyGrid } from '../common/grid.js';

type Data = { p: IPoint, v: IPoint }[];

function parse(fname: string) {
	const data = readFileSync(fname, { encoding: 'utf-8' }).split('\n').filter(i => i !== '');
	return data.map(line => {
		const m = line.match(/p=(?<px>-?\d+),(?<py>-?\d+) v=(?<vx>-?\d+),(?<vy>-?\d+)/);
		
		assert(m && m.groups);
		const { px, py, vx, vy } = m.groups;
		return { p : { x: Number(px), y: Number(py) }, v: { x: Number(vx), y: Number(vy) } };
	});
}

function applyIteration(data: Data, area: Point) {
	for (const row of data) {
		row.p = Point.plus(row.p, row.v).wrap(area);
	}
}

function solve1(raw: Data, area: Point) {
	const data = structuredClone(raw);
	for (let i = 0; i < 100; ++i) {
		applyIteration(data, area);
	}

	// assign quadrant to each
	const frqMap = new DefaultMap<number, number>(0);
	const middle = area.minus({x : 1, y: 1}).mul(0.5);
	for (const row of data) {
		// skip the ones on the center
		if (row.p.x === middle.x) continue;
		if (row.p.y === middle.y) continue;
		let idx = 0;
		if (row.p.x > middle.x) idx += 1;
		if (row.p.y > middle.y) idx += 2;
		frqMap.update(idx, val => val + 1);
	}

	let result = 1;
	for (const val of frqMap.values()) {
		result *= val;
	}

	return result;
}

function solve2(raw: Data, area: Point) {
	const data = structuredClone(raw);
	for (let i = 1; true; i++) {
		// const grid = createEmptyGrid(area, () => '.');
		const map = new Set<string>();
		applyIteration(data, area);
		for (const row of data) {
			map.add(row.p.toString());
			// grid.data[row.p.y][row.p.x] = '#';
		}

		// originally detected tree by finding a symmetry axis, which works.
		// but this suggestion from reddit is much simpler:
		// just repeat until every point is at a unique position
		if (map.size === data.length) {
			// uncomment this to see the tree!
			// console.log(grid.toString());
			return i;
		}
	}
}

assert(process.argv.length === 3, 'Expected argument: input filename');
const data = parse(process.argv[2]);
const area = process.argv[2].startsWith('test') ? new Point(11, 7) : new Point(101, 103);
const result = [ solve1(data, area), solve2(data, area) ];
console.log(result.join('\n'));
